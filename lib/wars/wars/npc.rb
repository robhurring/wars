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
      self.index += 1
      @id = attributes[:id] || self.index
      @name = attributes[:name] || 'Mystery Man'
      @strength = attributes[:strength] || DefaultStrength
      @defense = attributes[:defense] || DefaultDefense
      @life = @base_life = attributes[:life] || DefaultLife
      @rewards = attributes[:rewards]
      @condition = attributes[:condition] || nil
    end

    def eligible?(player)
      return true if @condition.blank?
      @condition.call(player)
    end

    # HACK: when class caching is on the NPC's health is still set to negatives from the
    # previous fight. this is just a bandaid
    def reset!
      @life = @base_life
    end
    
    def alive?
      life > 0
    end
    
    # returns [type, quantity] where type can be a +Product+, +Equipment+ or +:cash+
    def reward(player = nil)
      @rewards.call(player)
    end
  end
end