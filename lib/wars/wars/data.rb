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
      Equipment.new(:id => 4, :name => 'Medical Kit', :limit => 999, :price => 750, :adds => :life, :amount => 10, :disposable => true),
      Equipment.new(:id => 5, :name => 'IBM Keyboard', :limit => 1, :price => 20_000, :adds => :strength, :amount => 25),
      Equipment.new(:id => 6, :name => 'Mousing Star', :limit => 1, :price => 100_000, :adds => :strength, :amount => 50),
      Equipment.new(:id => 7, :name => 'Peacoat', :limit => 1, :price => 25_000, :adds => :defense, :amount => 25),
      # Non-Shop Special Rewards
      Equipment.new(:id => 100, :name => 'Orb of Life', :limit => 1, :price => 0, :adds => :life, :amount => 100),
      Equipment.new(:id => 101, :name => 'Thor\'s Hammer', :limit => 1, :price => 0, :adds => :strength, :amount => 50),
      Equipment.new(:id => 102, :name => 'Mustard Shirt', :limit => 1, :price => 0, :adds => :defense, :amount => 50)
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
      Equipment.find(5),
      Equipment.find(6),
      Equipment.find(7)
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
      Npc.new(
        :id => 1, 
        :name => 'Hall Monitor', 
        :strength => 20, 
        :defense => 0, 
        :life => 35, 
        :rewards => Proc.new{ [:cash, (500..1_000).rand] },
        :condition => Proc.new{ |p| p.strength < 50 }
      ),
      Npc.new(
        :id => 2, 
        :name => 'Annoying Co-Worker', 
        :strength => 35, 
        :defense => 0,
        :life => 80, 
        :rewards => Proc.new{ [Data.random_product, (1..5).rand] },
        :condition => Proc.new{ |p| p.strength < 75 }
      ),      
      # Bosses
      Npc.new(
        :id => 100,
        :name => 'Ajay',
        :strength => 65,
        :defense => 20,
        :life => 100,
        :rewards => Proc.new{ |p| Data.boss_reward(p, Equipment.find(100), (5_000..10_000)) },
        :condition => Proc.new{ |p| p.strength >= 35 }
      ),
      Npc.new(
        :id => 101,
        :name => 'Lumberg',
        :strength => 80,
        :defense => 30,
        :life => 200,
        :rewards => Proc.new{ |p| Data.boss_reward(p, Equipment.find(101), (10_000..30_000)) },
        :condition => Proc.new{ |p| p.strength >= 50 && rand(2) == 0 }
      ),
      Npc.new(
        :id => 102,
        :name => 'Dwight Shrute',
        :strength => 80,
        :defense => 100,
        :life => 350,
        :rewards => Proc.new{ |p| Data.boss_reward(p, Equipment.find(102), (50_000..100_000)) },
        :condition => Proc.new{ |p| p.strength >= 100 && rand(2) == 0 }
      )
    ]
    
    # Some random NPCs
    ['Michael Scott', 'Pam', 'Jim', 'Creed'].each do |npc_name|
      Npcs << Npc.new(
        :name => npc_name,
        :strength => (10..40).rand,
        :defense => (0..15).rand,
        :life => (85..125).rand,
        :rewards => Proc.new{ rand(2) == 0 ? [Data.random_product, (1..5).rand] : [:cash, (500..2_000).rand] }
      )
    end

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
    
    # Some random helpers for the data file
  
    def self.boss_reward(player, equipment, cash_range, quantity = 1, odds = 2)
      cash_prize = [:cash, cash_range.rand]
      if player.equipment.any?{ |e| e[:id] == equipment.id}
        cash_prize
      else
        if rand(odds).floor == 0
          [equipment, 1]
        else
          cash_prize
        end
      end
    end
    
  end
end