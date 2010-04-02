module Wars
  module Data
    MaxLoan = 30_000
    BookieName = 'Lumberg'
    BookieTolerance = 30 # days
    Encounters = true
    EncounterRate = 5 # days
    BankInterestRate = 1.0015
    DebtInterestRate = 1.15
    
    Equipments = [
      Equipment.new(:id => 1, :name => 'Messenger Bag', :limit => 1, :price => 10_000, :adds => :space, :amount => 30),
      Equipment.new(:id => 2, :name => 'Briefcase', :limit => 2, :price => 10_000, :adds => :space, :amount => 15),
      Equipment.new(:id => 3, :name => 'Backpack', :limit => 1, :price => 50_000, :adds => :space, :amount => 50),
      Equipment.new(:id => 4, :name => 'Medical Kit', :limit => 10, :price => 750, :adds => :life, :amount => 10, :disposable => true),
      Equipment.new(:id => 5, :name => 'Keyboard', :limit => 1, :price => 20_000, :adds => :strength, :amount => 10),
    ]
        
    Products = [
      Product.new(:id => 1, :name => 'Staples', :price_range => (10..70), :min_message => 'A truckload of staples has been hijacked! Cheap staples for everybody!', :max_message => 'All TPS reports must now be stapled! Staples are at an all-time high!'),
      Product.new(:id => 2, :name => 'Ties', :price_range => (200..500), :min_message => 'Employees are rebelling against Ties! Ties are extremely cheap!', :max_message => 'Management has mandated wearing of Ties. Ties are now extremely expensive!'),
      Product.new(:id => 3, :name => 'Computers', :price_range => (900..1500), :min_message => 'You notice stacks of computers in the hallway! Sweet!', :max_message => 'Management is basing your bonus on computer usage time! Computer prices have sky rocketed!'),
      Product.new(:id => 4, :name => 'Copier', :price_range => (2000..5200), :min_message => 'Somebody just threw a bunch of copiers out!', :max_message => 'Months end is approaching and people need to get their TPS repors copied!')
    ]
    
    Locations = [
      Location.new(:id => 1, :name => 'Parking Lot'),
      Location.new(:id => 2, :name => 'Lobby'),
      Location.new(:id => 3, :name => 'Cafeteria'),
      Location.new(:id => 4, :name => '1st Floor'),
      Location.new(:id => 5, :name => '2nd Floor'),
      Location.new(:id => 6, :name => '3d Floor'),
      Location.new(:id => 7, :name => 'Roof')
    ]
    
    GiftShopInventory = [
      Equipment.find(1),
      Equipment.find(2),
      Equipment.find(3)
    ]

    SurvivalEquipment = [
      Equipment.find(5)
    ]

    HospitalInventory = [
      Equipment.find(4)
    ]
            
    Stores = [
      Store.new(:location_id => 1, :name => 'a shady ATM', :sells => :bank),
      Store.new(:location_id => 1, :name => 'Loans \'R Us', :sells => :loans),
      Store.new(:location_id => 2, :name => 'Gift Shop', :sells => GiftShopInventory),
      Store.new(:location_id => 2, :name => 'Sensual Healing Hospice', :sells => HospitalInventory),
      Store.new(:location_id => 7, :name => 'Ajay\'s Survival Shop', :sells => SurvivalEquipment)
    ]

    Npcs = [
      Npc.new(:id => 1, :name => 'Hall Monitor', :strength => 5, :defense => 0, :life => 35, :rewards => :cash, :quantity => (500..1000)),
      Npc.new(:id => 2, :name => 'Annoying Co-Worker', :strength => 8, :defense => 0, :life => 80, :rewards => Proc.new{ Data.random_product }, :quantity => (1..5))
    ]

    Events = [
     Event.new(
      :description => "You found some money on the ground!",
      :condition => Proc.new{ rand(30) == 0 },
      :action => Proc.new{ self.cash += rand(1000) }
     ),
     Event.new(
      :description => "You found something shiny on the ground!",
      :condition => Proc.new{ rand(40) == 0 },
      :action => Proc.new{ 
        rand_product = Data.random_product.to_h.merge(:quantity => rand(5) + 1)
        self.products << rand_product
      }
     ),
     Event.new(
      :description => "#{BookieName} broke your legs! Better learn to pay up on time!",
      :condition => Proc.new{ |p| p.days_in_debt > BookieTolerance && !p.debt.zero? },
      :action => Proc.new{
        if self.cash > self.debt
          self.cash -= self.debt
          self.debt = 0
          self.days_in_debt = 0
          self.life /= 2
        else
          self.tombstone = "Pain sandwich courtesy of #{Data::BookieName}"
          self.life = 0
        end
      }
     )
    ]
    
    # When making a new player they start with these items/equipments by default
    StartingEquipment = [Equipment.find(1).to_h(:quantity => 1)]
    StartingProducts = []
    
    def self.random_product
      product = Data::Products[rand(Data::Products.size)].dup
      product.price = 0 # if it was used in an event, then free is the key
      product
    end
  end
end