require 'lib/environment'

class OfficeWars < Sinatra::Base
  Log = Logger.new('log/wars.log')

  enable :sessions, :cookies, :logging
  use Rack::Flash, :sweep => false, :accessorize => [:notice, :error, :attack]
  use Rack::Static, :urls => ['/css', '/images', '/js'], :root => 'public'    
  
  configure do
    Wars.logger = Log
  end

  before do
    Log.info("@: %s" % request.path.inspect)    
    Wars.initialize!(session)
    
    unless %w{/ /instructions /login /scores}.any?{ |path| request.path == path }
      setup_player || redirect(url_for '/login')
    end
    
    check_game_conditions
  end

  after do
    flash.flag!
    Wars.save(session)
  end

# Main

  get '/' do
    erb :index
  end
  
  get '/scores' do
    @scores = Wars::HighScore.top
    erb :scores
  end
  
  get '/instructions' do
    erb :instructions
  end
  
# Authentication

  get '/login' do
    erb :login
  end
  
  post '/login' do
    name = params[:name]
    pass = params[:password]
    new_user = params[:new_user]
    
    if Wars.login(name, pass, new_user)
      flash[:notice] = "Welcome back, #{Wars.player.name}!"
      redirect(url_for('/location/%d' % Wars.player.location_id))
    else
      if Wars.player
        flash[:error] = Wars.player.errors.full_messages.join('<br/>')
      else
        flash[:error] = 'Invalid name and/or password.'
      end
      erb :login
    end
  end
  
  get '/logout' do
    Wars.logout
    redirect(url_for('/'))
  end
  
  get '/quit' do
    @player.tombstone = 'Quit the Office :('
    Wars.game_over!
    flash[:error] = "You've quit the office. Come back again sometime and see the office is better :)"
    redirect(url_for('/scores'))
  end

# Fighting

  get '/fight' do
    @fight = @player.fight
    if @fight
      erb :fight
    else
      flash[:error] = "You aren't fighting!"
      redirect(url_for('/location/%d' % @player.location_id))
    end
  end
  
  get '/fight/run' do
    @fight = @player.fight
    
    if @fight
      npc = @fight.npc
      
      if @player.run(npc)
        # TODO: this can probably be changed to a better amount
        loss = @player.cash / (5 + rand(10))
        flash[:attack] = "You got away!<br/>But you dropped <strong>$#{format_number loss}</strong> while running away..."
        @fight.destroy
        @player.reset_fight_counter!
        redirect(url_for('/location/%d' % @player.location_id))
      else
        damage = npc.attack(@player)
        @player.life -= damage
        if @player.alive?
          flash[:attack] = "Can't escape!<br/><strong>#{npc.name}</strong> hits you for <strong>#{damage}</strong> damage!"
        else
          @player.tombstone = npc.name
          is_game_over?
        end
      end
      
    else
      flash[:error] = "You aren't in a fight!"
      redirect(url_for('/location/%d' % @player.location_id))
    end
    
    if request.xhr?
      partial :arena, :fight => @fight
    else
      erb :fight
    end
  end
  
  get '/fight/attack' do
    @fight = @player.fight
    
    if @fight
      npc = @fight.npc
      npc.life -= @fight.npc_damage_taken
      damage = @player.attack(npc)
      
      npc.life -= damage
      if npc.alive?
        @fight.update_attribute(:npc_damage_taken, @fight.npc_damage_taken + damage)
        # NPC fight back
        npc_damage = npc.attack(@player)
        @player.life -= npc_damage
        if @player.alive?
          flash[:attack] = "You whack <strong>#{npc.name}</strong> for <strong>#{damage}</strong> damage!<br/>#{npc.name} hits you for <strong>#{npc_damage}</strong> damage!"
        else
          @player.tombstone = npc.name
          is_game_over?
        end
      else
        @fight.destroy
        @player.reset_fight_counter!
        reward = npc.reward(@player)
        reward_msg = ''

        if reward.first == :cash
          @player.cash += reward.last
          reward_msg = "<br/>You took <strong>$#{format_number reward.last}</strong>."
        elsif reward.first.is_a?(Wars::Product)
          @player.update_products(reward.first.to_h(:quantity => reward.last))
          reward_msg = "<br/>You took <strong>#{reward.last} &times; #{reward.first.name}</strong>."
        elsif reward.first.is_a?(Wars::Equipment)
          @player.update_equipment(reward.first.to_h(:quantity => reward.last))
          reward_msg = "<br/>You took <strong>#{reward.last} &times; #{reward.first.name}</strong>."
        end
                
        flash[:attack] = "You've defeated <strong>#{npc.name}</strong> with a big hit for <strong>#{damage}</strong> damage!#{reward_msg}"
        redirect(url_for('/location/%d' % @player.location_id))
      end
    else
      flash[:error] = "You aren't in a fight!"
      redirect(url_for('/location/%d' % @player.location_id))
    end
    
    if request.xhr?
      partial :arena, :fight => @fight
    else
      erb :fight
    end
  end

# Moving
  
  get '/location/:id' do |id|
    new_location = Wars::Location.find(id.to_i)
    session[:in_store] = nil
    
    # we moved
    if new_location && new_location.id != @player.location_id
      Wars.log "Moved>\t#{new_location.name}"
      @player.location_id = new_location.id
      @player.live_another_day!
      Wars.update_prices!
      Wars.run_events!
      check_game_conditions
    else
      flash[:notice] = "Invalid Move!" if new_location.blank?
    end
    
    erb :stage
  end
  
  get '/store/:id' do |id|
    @store = Wars::Store.find(id.to_i)
    session[:in_store] = @store.id

    unless @store && @player.location_id == @store.location_id
      flash[:error] = "There is no such store here!"
      return redirect(url_for("/location/%d" % @player.location_id))
    end
    
    erb :stage
  end

# Buying / Selling Products
  
  post '/product/:id/buy/:quantity' do |id, quantity|
    product = Wars::Product.find(id.to_i)
    quantity = quantity.to_i.abs
    quantity = @player.space_available if Wars.auto_adjust_quantity && quantity > @player.space_available
    final_price = product.price * quantity
    
    if product
      @player.buy_product(product, quantity)
      
      error ||= @player.errors.on(:products)
    else
      error = 'This product doesn\t exist!'
    end
    
    unless error.blank?
      flash[:error] = error
    else
      flash[:notice] = "You bought #{quantity} &times; #{product.name} for $#{format_number final_price}!"
    end
    
    if request.xhr?
      partial :stage
    else
      redirect(url_for('/location/%s' % @player.location_id))
    end
  end
  
  post '/product/:index/sell/:quantity' do |index, quantity|
    index = index.to_i.abs
    quantity = quantity.to_i.abs
    item = @player.products[index.to_i]    
    quantity = item[:quantity] if Wars.auto_adjust_quantity && item && quantity > item[:quantity]

    if item
      product = Wars::Product.find(item[:id])
      price_difference = product.price - item[:price]
      sale_price = (item[:price] * quantity)
      profit = (price_difference * quantity)
      final_price = (sale_price + profit)
    end
  
    @player.sell_product(index, quantity)
    
    if error = @player.errors.on(:products)
      flash[:error] = error
    else
      if item && product
        flash[:notice] = "You sold #{quantity} &times; #{product.name} for $#{format_number final_price} and made $#{format_number profit} profit!"
      else
        flash[:notice] = "Dunno what you did. but you broke it..."
      end
    end
    
    if request.xhr?
      partial :stage
    else
      redirect(url_for('/location/%s' % @player.location_id))
    end
  end

# Buying / Selling Equipment

  post '/equipment/:id/buy/:quantity' do |id, quantity|
    # we need this so we load the stage properly
    @store = Wars::Store.find(session[:in_store]) if session[:in_store]
    
    equipment = Wars::Equipment.find(id.to_i)
    quantity = quantity.to_i.abs

    item = @player.equipment.detect{ |e| e[:id] == equipment.id }
    if Wars.auto_adjust_quantity
      if item
        quantity = (equipment.limit - item[:quantity]) if quantity > (equipment.limit - item[:quantity])
      else
        quantity = equipment.limit if quantity > equipment.limit
      end
    end
    final_price = equipment.price * quantity
    
    if equipment
      @player.buy_equipment(equipment, quantity)
      
      error ||= @player.errors.on(:equipment)
    else
      error = 'This equipment doesn\t exist!'
    end
    
    unless error.blank?
      flash[:error] = error
    else
      flash[:notice] = "You bought #{quantity} &times; #{equipment.name} for $#{format_number final_price}!"
    end
    
    if request.xhr?
      partial :stage
    else
      redirect(url_for('/location/%s' % @player.location_id))
    end
  end
  
  post '/equipment/:index/sell/:quantity' do |index, quantity|
    # we need this so we load the stage properly
    @store = Wars::Store.find(session[:in_store]) if session[:in_store]
    
    index = index.to_i.abs
    quantity = quantity.to_i.abs
    
    item = @player.equipment[index.to_i]    
    quantity = item[:quantity] if Wars.auto_adjust_quantity && item && quantity > item[:quantity]

    if item
      equipment = Wars::Equipment.find(item[:id])
      final_price = equipment.sale_price * quantity
    end
  
    @player.sell_equipment(index, quantity)
    
    if error = @player.errors.on(:equipment)
      flash[:error] = error
    else
      if item && equipment
        flash[:notice] = "You sold #{quantity} &times; #{equipment.name} for $#{format_number final_price}."
      else
        flash[:notice] = "Dunno what you did. but you broke it..."
      end
    end
    
    if request.xhr?
      partial :stage
    else
      redirect(url_for('/location/%s' % @player.location_id))
    end
  end
  
# Bank

  post '/bank/deposit/:amount' do |amount|
    @store = Wars::Store.all.detect{ |s| s.sells == :bank }
    
    amount = amount.to_i.abs
    amount = @player.cash if Wars.auto_adjust_bank && amount > @player.cash

    @player.deposit(amount)

    if error = @player.errors.on(:bank)
      flash[:error] = error
    else
      flash[:notice] = "You deposited $#{format_number amount} in the bank!"
    end
    
    if request.xhr?
      partial :stage
    else
      erb :stage
    end
  end
  
  post '/bank/withdrawl/:amount' do |amount|
    @store = Wars::Store.all.detect{ |s| s.sells == :bank }
    
    amount = amount.to_i.abs
    amount = @player.bank if Wars.auto_adjust_bank && amount > @player.bank
    
    @player.withdraw(amount)

    if error = @player.errors.on(:bank)
      flash[:error] = error
    else
      flash[:notice] = "You withdrew $#{format_number amount} from the bank."
    end

    if request.xhr?
      partial :stage
    else
      erb :stage
    end
  end

# Loans

  post '/loan/repay/:amount' do |amount|
    @store = Wars::Store.all.detect{ |s| s.sells == :loans }
    
    amount = amount.to_i.abs
    amount = @player.cash if Wars.auto_adjust_loan && amount > @player.cash
    amount = @player.debt if Wars.auto_adjust_loan && amount > @player.debt
    
    @player.repay(amount)

    if error = @player.errors.on(:debt)
      flash[:error] = error
    else
      flash[:notice] = "You re-paid $#{format_number amount} to #{Wars::Data::BookieName}!"
    end
    
    if request.xhr?
      partial :stage
    else
      erb :stage
    end
  end
  
  post '/loan/borrow/:amount' do |amount|
    @store = Wars::Store.all.detect{ |s| s.sells == :loans }
    
    amount = amount.to_i.abs    
    amount = (Wars::Data::MaxLoan - @player.debt) if Wars.auto_adjust_loan && (amount + @player.debt) > Wars::Data::MaxLoan
    
    @player.borrow(amount)
    
    if error = @player.errors.on(:debt)
      flash[:error] = error
    else
      flash[:notice] = "You borrowed $#{format_number amount} from #{Wars::Data::BookieName}, better pay it back quick!"
    end
    
    if request.xhr?
      partial :stage
    else
      erb :stage
    end
  end

# Bulletins

  post '/post_bulletin' do
    @store = Wars::Store.all.detect{ |s| s.sells == :bulletins }
    
    if @player.cash < Wars::Data::BulletinCost
      error = "You can't afford to post a bulletin! You need $#{format_number Wars::Data::BulletinCost}"
    else
      bulletin = Wars::Bulletin.new(
        :name => @player.name,
        :message => params[:message],
        :ip => request.ip,
        :checked => false)
        
      if bulletin.save
        @player.cash -= Wars::Data::BulletinCost
      else
        @message = bulletin.message
        error = bulletin.errors.full_messages.join('<br/>')
      end
    end
    
    if error
      flash[:error] = error
    else
      flash[:notice] = "Your message was posted!"
    end
    
    if request.xhr?
      partial :stage
    else
      erb :stage
    end
  end

# Support

private

  def check_game_conditions
    unless Wars.event.blank?
      flash[:notice] = Wars.event.description
      is_game_over?
    end
     
    if is_fighting? && !request.path.include?('fight')
      redirect(url_for('/fight'))
    end
    
    is_game_over?
  end

  def is_fighting?
    @player && !@player.fight.blank?
  end

  def is_game_over?
    return unless @player
    is_game_over = false
    
    if @player.day > Wars::Data::MaxDays && !Wars::Data::MaxDays.zero?
      is_game_over = true
      flash[:notice] = "Congratulations, you survived! You can now retire!"
      @player.tombstone = 'Peacefully retired.'
    end
    
    unless @player.alive?
      flash[:error] = "You are dead! Game Over!"
      is_game_over = true
    end
    
    if is_game_over
      @player = nil
      Wars.game_over!
      redirect(url_for('/scores'))
    end
  end

  def playing?
    @player && @player.alive?
  end
  
  def setup_player
    return nil unless Wars.player
    @player = Wars.player
  end
end