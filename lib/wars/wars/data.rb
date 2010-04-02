module Wars
  module Data
    MaxLoan = 30_000
    BookieTolerance = 30 # days
    Encounters = true
    EncounterRate = 5 # days
    BankInterestRate = 1.0015
    DebtInterestRate = 1.15
    
    Equipments = [
      Equipment.new(:id => 1, :name => 'Messenger Bag', :limit => 1, :price => 10_000, :adds => :space, :amount => 30),
      Equipment.new(:id => 2, :name => 'Briefcase', :limit => 2, :price => 10_000, :adds => :space, :amount => 15),
      Equipment.new(:id => 3, :name => 'Backpack', :limit => 1, :price => 50_000, :adds => :space, :amount => 50),
      Equipment.new(:id => 4, :name => 'Medical Kit', :limit => 10, :price => 750, :adds => :life, :amount => 10, :disposable => true)
    ]
        
    Products = [
      Product.new(:id => 1, :name => 'Staples', :price_range => (10..70), :min_message => 'A truckload of staples has been hijacked! Cheap staples for everybody!', :max_message => 'All TPS reports must now be stapled! Staples are at an all-time high!'),
      Product.new(:id => 2, :name => 'Ties', :price_range => (200..500), :min_message => 'Employees are rebelling against Ties! Ties are extremely cheap!', :max_message => 'Management has mandated wearing of Ties. Ties are now extremely expensive!'),
      Product.new(:id => 3, :name => 'Computers', :price_range => (900..1500), :min_message => 'You notice stacks of computers in the hallway! Sweet!', :max_message => 'Management is basing your bonus on computer usage time! Computer prices have sky rocketed!'),
      Product.new(:id => 4, :name => 'Copier', :price_range => (2000..5200), :min_message => 'Somebody just threw a bunch of copiers out!', :max_message => 'Months end is approaching and people need to get their TPS repors copied!')
    ]
    
    Locations = [
      Location.new(:name => 'Parking Lot'),
      Location.new(:name => 'Lobby'),
      Location.new(:name => 'Cafeteria'),
      Location.new(:name => '1st Floor'),
      Location.new(:name => '2nd Floor'),
      Location.new(:name => '3d Floor'),
      Location.new(:name => 'Roof')
    ]
    
    GiftShopInventory = [
      Equipment.find(1),
      Equipment.find(2),
      Equipment.find(3)
    ]

    HospitalInventory = [
      Equipment.find(4)
    ]
            
    Stores = [
      Store.new(:location_id => 1, :name => 'a shady ATM', :sells => :bank),
      Store.new(:location_id => 1, :name => 'Loans \'R Us', :sells => :loans),
      Store.new(:location_id => 2, :name => 'Gift Shop', :sells => GiftShopInventory),
      Store.new(:location_id => 2, :name => 'Sensual Healing Hospice', :sells => HospitalInventory)
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
        rand_product = Data::Products[rand(Data::Products.size)].to_h.merge(:quantity => rand(5) + 1)
        self.products << rand_product
      }
     ),
     Event.new(
      :description => "The bookie broke your legs! Better learn to pay up on time!",
      :condition => Proc.new{ |p| p.days_in_debt > Data::BookieTolerance && !p.debt.zero? },
      :action => Proc.new{
        if self.cash > self.debt
          self.cash -= self.debt
          self.life /= 2
        else
          self.tombstone = "Pain sandwich via the Bookie."
          self.life = 0
        end
      }
     )
    ]
    
    # When making a new player they start with these items/equipments by default
    StartingEquipment = [Equipment.find(1).to_h(:quantity => 1)]
    StartingProducts = []
  end
end