module Wars
  class Npc
    cattr_accessor :index
    self.index = 0

    DefaultStrength = 10
    DefaultDefense = 10
    DefaultLife = 100
    
    def self.all
      @@all ||= Data::Npcs
    end
    
    def self.find(id)
      all.detect{ |o| o.id == id.to_i }
    end

    attr_reader :id, :name, :strength, :defense, :life
    
    def initialize(attributes = {})
      @id = attributes[:id] || (self.index += 1)
      @name = attributes[:name] || 'Mystery Man'
      @strength = attributes[:strength] || DefaultStrength
      @defense = attributes[:defense] || DefaultDefense
      @life = attributes[:life] || DefaultLife
    end
    
    def alive?
      life > 0
    end
  end
end