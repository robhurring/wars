module Wars
  class Location
    cattr_accessor :index
    self.index = 0
    
    def self.all
      @@all ||= Data::Locations
    end
    
    def self.find(id)
      all.detect{ |location| location.id == id.to_i }
    end
    
    attr_reader :id, :name
    
    def initialize(attributes = {})
      @id = attributes[:id] || (self.index += 1)
      @name = attributes[:name] || 'Unknown!'
    end

    def stores
      @stores ||= Store.in(id)
    end
  end
end