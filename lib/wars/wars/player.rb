require 'digest/sha1'

module Wars
  class Player < ActiveRecord::Base    
    include Fighter
    
    MaxLife = 100
    StartingSpace = 10
    StartingDefense = 10
    StartingStrength = 10
    StartingAttributes = {
      :life => MaxLife,
      :cash => 5_000,
      :debt => 2_500,
      :bank => 0,
      :location_id => 1,
      :day => 1,
      :days_in_debt => 1,
      :days_without_incident => 0,
      :equipment => (Data::StartingEquipment || []),
      :products => (Data::StartingProducts || [])
    }
    
    def self.crypt_password(password)
      Digest::SHA1.hexdigest("--WARZ!--#{password}--")
    end

    def self.default(name, password)
      new(StartingAttributes.merge(:name => name, :password => crypt_password(password)))
    end

    def self.login(name, password)
      first(:conditions => {:name => name, :password => crypt_password(password)})
    end

    # this should be set when the player is killed for the HighScore.reason
    attr_accessor :tombstone

    has_one :fight, :dependent => :destroy

    validates_uniqueness_of :name
    validates_presence_of :password

    serialize :equipment, Array
    serialize :products, Array
  
    # loads our equipment into Equipment objects, with thier quantity
    def equipment_map
      equipment.map{ |e| [Equipment.find(e[:id]), e[:quantity]]}
    end
    
    # loads our products into Product objects and their quantity
    def product_map
      products.map{ |p| [Product.find(p[:id]), p[:quantity]] }
    end
  
    def strength
      StartingStrength + equipment_total(:strength)
    end
    
    def defense
      StartingDefense + equipment_total(:defense)
    end
  
    def score
      total_products = products.inject(0){ |t, p| t + (p[:price] * p[:quantity]) }
      total_products + cash + bank - debt
    end
  
    def space
      @space ||= StartingSpace + equipment_total(:space)
    end
    
    def held
      product_map.sum{ |p| p.last }
    end
    
    def can_carry?(quantity = 0)
      space_available >= quantity
    end
    
    def space_available
      (space - held)
    end

    def equipment_total(adds)
      equipment_map\
        .select{ |e| e.first.adds == adds }\
        .inject(0){ |t, e| t += (e.first.amount * e.last); t }
    end
    
    def alive?
      life > 0
    end
  
    def live_another_day!
      self.bank = (self.bank * Data::BankInterestRate).ceil
      self.debt = (self.debt * Data::DebtInterestRate).ceil
      self.day += 1
      self.days_in_debt += 1 if self.debt > 0
      self.days_in_debt = 0 if self.debt.zero?
      self.days_without_incident += 1
    end
    
    def reset_fight_counter!
      self.days_without_incident = 0
    end
    
    def deposit(amount)
      error = ''
      error = 'You don\'t have that much money!' if amount > self.cash
      error = 'Wow. Big spender, huh?' if amount.zero?
      
      if error.blank?
        self.bank += amount
        self.cash -= amount
      else
        errors.add(:bank, error)
      end
    end
    
    def withdraw(amount)
      error = ''
      error = 'You don\'t have that much to withdraw!' if amount > self.bank
      error = 'We\'re such a good bank, we let you withdraw $0!' if amount.zero?

      if error.blank?
        self.bank -= amount
        self.cash += amount
      else
        errors.add(:bank, error)
      end
    end
    
    def repay(amount)
      error = ''
      error = 'Stop giving your money away!' if self.debt.zero?
      error = 'You don\'t have that much money!' if amount > self.cash
      error = 'You don\'t owe that much money!' if amount > self.debt
      
      if error.blank?
        self.debt -= amount
        self.cash -= amount
      else
        errors.add(:debt, error)
      end
    end
    
    def borrow(amount)
      error = ''
      error = 'That was easy! You only needed $0?' if amount.zero?
      if (amount + self.debt) > Data::MaxLoan
        error = "You are allowed to borrow $#{Data::MaxLoan.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')} MAX. You'll go over if you borrow that much."
      end
      
      if error.blank?
        self.debt += amount
        self.cash += amount
      else
        errors.add(:debt, error)
      end
    end
  
    def sell_product(index, quantity)
      item = self.products[index]
      error = ''
      
      if item
        price_difference = Wars::Product.find(item[:id]).price - item[:price]
        sale_price = (item[:price] * quantity)
        profit = (price_difference * quantity)
        
        quantity = item[:quantity] if quantity > item[:quantity]
        
        unless quantity.zero?
          update_products(item.dup.merge(:quantity => quantity), false)
          self.cash += (sale_price + profit)
        else
          error = 'You can\'t sell 0 of something!'
        end
      else
        error = 'You aren\'t carrying any of this product!'
      end
      
      errors.add(:products, error) unless error.blank?
    end
    
    # update the products array or add a new product with the given product hash
    def update_products(product_hash, adding = true)
      existing = products.detect{ |p| p[:id] == product_hash[:id] && p[:price] == product_hash[:price] }
      if adding
        if existing
          existing[:quantity] += product_hash[:quantity]
        else
          products << product_hash
        end
      else
        existing_index = products.index(existing)
        existing[:quantity] -= product_hash[:quantity]
        self.products.delete_at(existing_index) if existing[:quantity] <= 0
      end
    end
    
    # do the error checking and cash math for purchasing a product
    def buy_product(product, quantity)
      error = ''
      item = products.detect{ |p| p[:id] == product.id && p[:price] == product.price }
      
      error = 'You can\'t afford this!' if (product.price * quantity) > self.cash
      error = 'You don\'t have enough room!' unless can_carry?(quantity)
      
      if error.blank?
        unless quantity.zero?
          update_products product.to_h(:quantity => quantity)          
          self.cash -= (product.price.to_i * quantity.to_i)
        else
          error = 'You want to buy 0 of something?'
        end
      end
      
      errors.add(:products, error) unless error.blank?
    end
    
    def sell_equipment(index, quantity)
      item = self.equipment[index]
      error = ''
      
      if item        
        equipment = Equipment.find(item[:id])
        quantity = item[:quantity] if quantity > item[:quantity]
        if equipment
          unless quantity.zero?
            update_equipment(item.dup.merge(:quantity => quantity), false)            
            self.cash += equipment.sale_price
          else
            error = 'You can\'t sell 0 of something!'
          end
        else
          error = 'This equipment doesn\'t exist!'
        end
      else
        error = 'You aren\'t carrying any of this product!'
      end
      
      errors.add(:equipment, error) unless error.blank?
    end
    
    # update the products array or add a new product with the given product hash
    def update_equipment(equipment_hash, adding = true)
      existing = equipment.detect{ |p| p[:id] == equipment_hash[:id] }
      
      if adding
        eq = Equipment.find(equipment_hash[:id])
        # Apply equipment benefits
        equipment_hash[:quantity].times do 
          amount = eq.amount
          case eq.adds
          when :life
            self.life += amount
            self.life = MaxLife if self.life > MaxLife
          end
        end
        
        # Add equipment to our inventory
        unless eq.disposable?
          if existing
            existing[:quantity] += equipment_hash[:quantity]
          else
            equipment << equipment_hash
          end
        end
      else
        existing_index = equipment.index(existing)
        existing[:quantity] -= equipment_hash[:quantity]
        self.equipment.delete_at(existing_index) if existing[:quantity] <= 0
      end
    end
    
    def buy_equipment(equipment, quantity)
      item = self.equipment.detect{ |e| e[:id] == equipment.id }      
      
      error = ''
      error = 'You can\'t afford this!' if (equipment.price.to_i * quantity) > self.cash
      error = 'You aren\'t allowed to carry that many!' if item && item[:quantity] >= equipment.limit
      
      if error.blank?
        unless quantity.zero?
          update_equipment(equipment.to_h(:quantity => quantity))
          self.cash -= (equipment.price.to_i * quantity)
        else
          error = 'You want to buy 0 of something? Not very smart.'
        end
      end
      
      errors.add(:equipment, error) unless error.blank?
    end
    
    
  end
end