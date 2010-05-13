module Wars
  class Equipment
    cattr_accessor :index
    self.index = 0
    
    def self.all
      @@all ||= Data::Equipments
    end
    
    def self.find(id)
      all.detect{ |equipment| equipment.id == id.to_i }
    end
    
    attr_reader :id, :name, :price, :limit, :adds, :amount, :disposable
    alias_method :disposable?, :disposable
    
    def initialize(attributes = {})
      @id = attributes[:id] || (self.index += 1)
      @name = attributes[:name]
      @price = attributes[:price] || 0
      @limit = attributes[:limit] || 1
      @adds = attributes[:adds].to_sym
      @amount = attributes[:amount] || 0
      @disposable = attributes[:disposable] || false
    end

    def sale_price
      (@price / 2).ceil
    end
   
    def to_h(with = {})
      {:id => id}.merge(with)
    end
    
    # how many of this equipment is the player allowed to purchase
    def quantity(player)
      carrying = player.equipment.detect{ |e| e[:id] == id }
      allowed = \
        if adds == :life && disposable?
          if amount > player.max_life && player.life < player.max_life
            1
          else
            ((player.max_life - (player.life - (player.life % amount))) / amount).ceil
          end
        else
          if carrying
            (limit - carrying[:quantity])
          else
            limit
          end
        end
      allowed
    end
    
  end
end