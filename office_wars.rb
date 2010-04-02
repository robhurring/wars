require 'lib/environment'

class OfficeWars < Sinatra::Base
  Log = Logger.new('log/wars.log')

  enable :sessions, :cookies, :logging
  use Rack::Flash, :sweep => true, :accessorize => [:notice, :error]

  configure do
    Wars.logger = Log
  end

  before do
    Wars.initialize!(session)
    setup_player || redirect(url_for '/login') unless request.url.include?('/login') || request.url.include?('/scores')
    is_fighting? && redirect(url_for('/fight')) unless request.url.include?('/fight')
    is_game_over?
  end

  after do
    Wars.save(session)# && !request.xhr?
  end

# Begin

  get '/' do
    erb :index
  end
  
  get '/scores' do
    erb :scores
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
      redirect(url_for('/location/%d' % Wars.player.location_id))
    else
      if Wars.player
        @errors = Wars.player.errors.full_messages.join('<br/>')
      else
        @errors = 'Invalid name and/or password.'
      end
      erb :login
    end
  end
  
  get '/logout' do
    Wars.logout
    redirect(url_for('/'))
  end

# Fighting

  get '/fight' do
    @fight = @player.fight
    @opponent = @fight.opponent
    
    erb :fight
  end
  
  post '/fight/flee' do
  end
  
  post '/fight/attack' do
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
      unless Wars.event.blank?
        flash[:notice] = Wars.event.description
        is_game_over?
      end
    else
      flash[:notice] = "Invalid Move!" if new_location.blank?
    end
    
    erb :game
  end
  
  get '/store/:id' do |id|
    @store = Wars::Store.find(id.to_i)
    session[:in_store] = @store.id

    unless @store && @player.location_id == @store.location_id
      flash[:error] = "There is no such store here!"
      return redirect(url_for("/location/%d" % @player.location_id))
    end
    
    erb :game
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
        flash[:notice] = "You sold #{quantity} &times; #{product.name} for $#{format_number final_price} and made $#{format_number profit}"
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
      erb :game
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
      erb :game
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
      flash[:notice] = "You re-paid $#{format_number amount} to the bookie!"
    end
    
    if request.xhr?
      partial :stage
    else
      erb :game
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
      flash[:notice] = "You borrowed $#{format_number amount} to the bookie, better pay it back quick!"
    end
    
    if request.xhr?
      partial :stage
    else
      erb :game
    end
  end

# Support

private

  def is_fighting?
    @player && !@player.fight.blank?
  end

  def is_game_over?
    if @player && !@player.alive?
      @player = nil
      Wars.game_over!
      flash[:error] = "Game Over!"
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