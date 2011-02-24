module Wars
  module Data
    MaxDays = 500
    MaxLoan = 30_000
    BookieName = 'Lumbergh'
    BookieTolerance = 30 # days
    Encounters = true
    EncounterRange = (3..7) # days
    BankInterestRate = 1.0015
    DebtInterestRate = 1.15
    BulletinCost = 25_000
    BulletinLength = 140
    
    Equipments = [
      Equipment.new(:id => 1, :name => 'Messenger Bag', :limit => 1, :price => 10_000, :adds => :space, :amount => 30),
      Equipment.new(:id => 2, :name => 'Briefcase', :limit => 2, :price => 10_000, :adds => :space, :amount => 15),
      Equipment.new(:id => 3, :name => 'Backpack', :limit => 1, :price => 50_000, :adds => :space, :amount => 50),
      Equipment.new(:id => 4, :name => 'Band-Aid', :limit => 999, :price => 750, :adds => :life, :amount => 10, :disposable => true),
      Equipment.new(:id => 5, :name => 'IBM Keyboard', :limit => 1, :price => 20_000, :adds => :strength, :amount => 25),
      Equipment.new(:id => 6, :name => 'Mousing Star', :limit => 1, :price => 100_000, :adds => :strength, :amount => 50),
      Equipment.new(:id => 7, :name => 'Peacoat', :limit => 1, :price => 25_000, :adds => :defense, :amount => 25),
      Equipment.new(:id => 8, :name => 'Medical Kit', :limit => 999, :price => 6_000, :adds => :life, :amount => 100, :disposable => true),
      Equipment.new(:id => 9, :name => 'Full Heal', :limit => 1, :price => 20_000, :adds => :life, :amount => 1_000, :disposable => true),
      Equipment.new(:id => 10, :name => 'Heart', :limit => 5, :price => 1_000_000, :adds => :life, :amount => 50),
      # Non-Shop Special Rewards
      Equipment.new(:id => 100, :name => 'Coffee Mug', :limit => 1, :price => 0, :adds => :life, :amount => 100),
      Equipment.new(:id => 101, :name => 'Rons Bat', :limit => 1, :price => 0, :adds => :strength, :amount => 50),
      Equipment.new(:id => 102, :name => 'Mustard Colored Shirt', :limit => 1, :price => 0, :adds => :defense, :amount => 50),
      Equipment.new(:id => 103, :name => 'Jims Messenger Bag', :limit => 1, :price => 0, :adds => :space, :amount => 80),
      Equipment.new(:id => 104, :name => 'Blakes Brass Balls', :limit => 1, :price => 0, :adds => :space, :amount => 300)
    ]
        
    Products = [
      Product.new(:id => 1, :name => 'Paper', :price_range => (10..70), :min_message => 'The amazon rain forest has just succumb to loggers. Paper is extremely cheap!', :max_message => 'Where did all the trees go? Paper prices have gone up dramatically!'),
      Product.new(:id => 2, :name => 'Ties', :price_range => (200..500), :min_message => 'Employees are rebelling against Ties! Ties are extremely cheap!', :max_message => 'Management has mandated wearing of Ties. Ties are now extremely expensive!'),
      Product.new(:id => 3, :name => 'Dell Desktop', :price_range => (900..1800), :min_message => 'The new Windows OS is riddled with bugs! People are dumping their PCs into the dumpster!', :max_message => 'Dell just upgraded their hardware! Computer prices have jumped!'),
      Product.new(:id => 5, :name => 'Optimus Keyboard', :price_range => (2400..5000), :min_message => 'Art Lebedev Studios just threw out a bunch of failed Optimus prototypes!', :max_message => 'The Optimus keyboard is running out of stock! Prices are soaring!'),
      Product.new(:id => 6, :name => 'MacBook Pro', :price_range => (3500..7800), :min_message => 'Apple\'s new hardware is riddled with DRM! People are selling MacBooks at an all time low!', :max_message => 'Apple is upgrading their hardware! Prices are skyrocketing!'),
      Product.new(:id => 4, :name => 'Copier', :price_range => (10000..15000), :min_message => 'Somebody just threw a bunch of copiers out!', :max_message => 'Months end is approaching and people need to get their TPS repors copied!')
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
      Equipment.find(4),
      Equipment.find(8),
      Equipment.find(9),
      Equipment.find(10)
    ]
            
    Stores = [
      Store.new(:location_id => 1, :name => 'a shady ATM', :sells => :bank),
      Store.new(:location_id => 1, :name => 'Lumbergh', :sells => :loans),
      Store.new(:location_id => 2, :name => 'Company Gift Shop', :sells => GiftShopInventory),
      Store.new(:location_id => 2, :name => 'Company Nurse', :sells => HospitalInventory),
      Store.new(:location_id => 7, :name => 'Dwight\'s Survival Shop', :sells => SurvivalEquipment),
      Store.new(:location_id => 3, :name => 'Message Board', :sells => :bulletins)
    ]

    Npcs = [
      # Bosses
      Npc.new(
        :id => 100,
        :name => 'Lumbergh',
        :strength => 45,
        :defense => 18,
        :life => 100,
        :rewards => Proc.new{ |p| Data.boss_reward(p, Equipment.find(100), (10_000..20_000), 1, 1) },
        :condition => Proc.new{ |p| p.strength >= 50 }
      ),
      Npc.new(
        :id => 101,
        :name => 'Ron Livingston',
        :strength => (55..65).rand,
        :defense => (25..30).rand,
        :life => (150..200).rand,
        :rewards => Proc.new{ |p| Data.boss_reward(p, Equipment.find(101), (25_000..50_000), 1, 1) },
        :condition => Proc.new{ |p| p.strength >= 50 && p.max_life > 100 }
      ),
      Npc.new(
        :id => 102,
        :name => 'Jim Halpert',
        :strength => 50,
        :defense => 100,
        :life => 250,
        :rewards => Proc.new{ |p| Data.boss_reward(p, Equipment.find(103), (50_000..75_000), 1, 1) },
        :condition => Proc.new{ |p| p.strength > 50 }
      ),
      Npc.new(
        :id => 103,
        :name => 'Dwight Shrute',
        :strength => 75,
        :defense => 80,
        :life => 350,
        :rewards => Proc.new{ |p| Data.boss_reward(p, Equipment.find(102), (75_000..100_000), 1, 1) },
        :condition => Proc.new{ |p| p.strength >= 100 }
      ),
      Npc.new(
        :id => 104,
        :name => 'Blake',
        :strength => 100,
        :defense => 140,
        :life => 500,
        :rewards => Proc.new{ |p| Data.boss_reward(p, Equipment.find(104), (200_000..500_000), 1, 1) },
        :condition => Proc.new{ |p| p.strength >= 150 && p.defense >= 85 }
      )
    ]
    
    # Easy NPCs -- can be shrugged off with a little defense so they can focus on trading. Weak product drops
    ['Milton', 'Ajay', 'Michael Scott', 'Creed', 'Andy', 'Toby'].each do |npc_name|
      Npcs << Npc.new(
        :name => npc_name,
        :strength => (10..25).rand,
        :defense => (0..10).rand,
        :life => (85..125).rand,
        :rewards => Proc.new{ rand(2) == 0 ? [Data.random_product(1,2,3), (1..5).rand] : [:cash, (500..2_000).rand] },
        :condition => Proc.new{ |p| p.strength <= Player::StartingStrength }
      )
    end
    
    # Medium NPCs -- player went the fighting route by buying weapons. Better product drops
    ['Ricky Roma', 'Shelley Levene', 'John Williamson', 'Buddy Ackerman', 'Dawn Lockard', 'Guy'].each do |npc_name|
      Npcs << Npc.new(
        :name => npc_name,
        :strength => (35..65).rand,
        :defense => (0..20).rand,
        :life => (85..125).rand,
        :rewards => Proc.new{ rand(2) == 0 ? [Data.random_product(3,4,5,6), (1..5).rand] : [:cash, (2_500..6_000).rand] },
        :condition => Proc.new{ |p| p.strength > 25 && p.strength < 100 }
      )
    end

    Events = [
     Event.new(
      :description => "You found some money on the ground!",
      :condition => Proc.new{ rand(30) == 0 },
      :action => Proc.new{ |p| p.cash += rand(1000) }
     ),
     Event.new(
      :description => "You found something on the ground!",
      :condition => Proc.new{ rand(40) == 0 },
      :action => Proc.new{ |p| 
        p.update_products random_product.to_h(:quantity => rand(5) + 1)
      }
     ),
     Event.new(
      :description => "#{BookieName} broke your legs! Better learn to pay up on time!",
      :condition => Proc.new{ |p| p.days_in_debt > BookieTolerance && !p.debt.zero? },
      :action => Proc.new{ |p|
        if p.cash > p.debt
          p.cash -= p.debt
          p.debt = 0
          p.days_in_debt = 0
          p.life /= 2
        else
          p.death_description = {
            :reason => :bookie,
            :message => "Pain sandwich courtesy of #{Data::BookieName}"
          }
          p.life = 0
        end
      }
     )
    ]
    
    # When making a new player they start with these items/equipments by default
    StartingEquipment = [Equipment.find(1).to_h(:quantity => 1)]
    StartingProducts = []
    
    # Select a random product from the list of ID's (or all) to award for an NPC fight
    def self.random_product(*product_ids)
      product_ids = Data::Products.map(&:id) if product_ids.empty?
      pool = Data::Products.select{ |p| product_ids.include?(p.id) }
      
      product = pool[rand(pool.size)].dup
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