module Wars
  class Npc
    include Fighter
    
    cattr_accessor :index
    self.index = 0

    DefaultStrength = 10
    DefaultDefense = 10
    DefaultLife = 50
    
    def self.all
      @@all ||= Data::Npcs
    end
    
    def self.find(id)
      all.detect{ |o| o.id == id.to_i }
    end

    attr_reader :id, :name, :strength, :defense
    attr_accessor :life
    
    def initialize(attributes = {})
      @id = attributes[:id] || (self.index += 1)
      @name = attributes[:name] || 'Mystery Man'
      @strength = attributes[:strength] || DefaultStrength
      @defense = attributes[:defense] || DefaultDefense
      @life = @base_life = attributes[:life] || DefaultLife
      @rewards = attributes[:rewards] || :cash # can also be a Product | Equipment
      @quantity = attributes[:quantity] || 1
    end

    # HACK: when class caching is on the NPC's health is still set to negatives from the
    # previous fight. this is just a bandaid
    def reset!
      @life = @base_life
    end
    
    def alive?
      life > 0
    end
    
    def quantity
      @quantity.is_a?(Range) ? (@quantity.min + rand(@quantity.max - @quantity.min)) : @quantity
    end
    
    # returns [type, quantity]
    def reward      
      [(@rewards.respond_to?(:call) ? @rewards.call : @rewards), quantity]
    end
  end
end