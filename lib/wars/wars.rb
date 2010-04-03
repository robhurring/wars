$: << File.dirname(__FILE__)

module Wars
  autoload :Player, 'wars/player'
  autoload :Product, 'wars/product'
  autoload :Equipment, 'wars/equipment'
  autoload :Location, 'wars/location'
  autoload :Store, 'wars/store'
  autoload :Event, 'wars/event'
  autoload :Data, 'wars/data'
  autoload :Npc, 'wars/npc'
  autoload :Fight, 'wars/fight'
  autoload :HighScore, 'wars/high_score'
  autoload :Fighter, 'wars/fighter'
  
  mattr_accessor :logger
  def self.log(msg, level=:info); self.logger.send(level, "Wars> #{msg}") if self.logger end

  mattr_accessor :session_key
  self.session_key = :wars
  
  # if quantity > allowed then quantity = allowed
  mattr_accessor :auto_adjust_quantity
  self.auto_adjust_quantity = true  
  
  # if amount > allowed then amount = allowed
  mattr_accessor :auto_adjust_bank
  self.auto_adjust_bank = true
    
  mattr_accessor :auto_adjust_loan
  self.auto_adjust_loan = true
    
# Game Methods

  mattr_accessor :products, :event, :player, :session
  
  def self.initialize!(app_session)
    srand

    log "Starting"
    self.products = Product.all
    self.session = (app_session[self.session_key] ||= {})
    self.player = find_player
    self.event = nil
    
    if session[:prices]
      load
    else
      update_prices!
    end
  end
    
  # do whatever we need to to persist our game -- namely product prices
  def self.save(app_session)
    log "Saving...\n"
    player.save if player && player.changed?
    app_session[self.session_key][:prices] = []
    self.products.each{ |p| app_session[self.session_key][:prices] << p.to_h }
  end
  
  # reload from persisted data -- namely product prices
  def self.load
    log "Loading..."
    if prices = session[:prices]
      prices.each do |stash|
        product = Product.find(stash[:id])
        product.price = stash[:price]
        log "\t#{product.name} set to $#{stash[:price]}"
      end
    end
  end
  
  def self.run_player_events
    Wars.log "Running player events"
    Data::Events.each do |event|
      if event.apply(player)
        self.event = event
      end
    end    
  end
  
  def self.run_fight_events
    Wars.log "Running fight events"
    if Data::Encounters
      if player.days_without_incident > Data::EncounterRate
        fight = Fight.new(:player => self.player)
        npc = Npc.all[rand(Npc.all.size)]
        # HACK: this sets the npc's life back to the original life. 
        npc.reset!
        fight.npc_id = npc.id
        fight.save
      end
    end
  end

  def self.run_events!
    run_player_events
    run_fight_events
  end

  def self.update_prices!
    log "Updating prices"
    srand
    self.products.each{ |p| p.update_price! }
  end
  
  def self.find_player
    Player.find(session[:player_id]) if session[:player_id]
  end
  
  def self.logout
    session.delete(:player_id)
    self.player = nil
  end
  
  def self.login(name, password, new_user = false)
    if new_user
      player = Player.default(name, password)
      player.save
    else
      player = Player.login(name, password)
    end
    
    if player && player.errors.blank?
      self.player = player
      session[:player_id] = player.id
    else
      return false
    end
  end
  
  def self.game_over!
    raise "No player?!" if player.blank?
    reason = player.tombstone || 'Natural Causes'
    score = HighScore.new(:name => player.name, :score => player.score, :day => player.day, :reason => reason)
    if score.save
      player.destroy
      logout
    else
      raise "Wtf. score didnt save..."
    end
  end
end
