module Wars
  class Store
    cattr_accessor :index
    self.index = 0

    def self.all
      @@all ||= Data::Stores
    end

    def self.find(id)
      all.detect{ |s| s.id == id }
    end

    def self.in(id)
      all.select{ |s| s.location_id == id }
    end
    
    attr_reader :id, :location_id, :name, :sells
    
    def initialize(attributes = {})
      @id = attributes[:id] || (self.index += 1)
      @location_id = attributes[:location_id] || 1
      @name = attributes[:name]
      @sells = attributes[:sells]
    end
  end
end