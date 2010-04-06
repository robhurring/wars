module Wars
  class Product
    cattr_accessor :index
    self.index = 0
    
    def self.all
      @@all ||= Data::Products
    end
    
    def self.find(id)
      all.detect{ |product| product.id == id.to_i }
    end
    
    # prices are multipled or divided by this if they are high/low
    HighLowRate = 3 
    # rand(RAND) -> 1 = price*=RATE , 0 = price/=RATE
    HighLowRand = 30 
    
    attr_reader :id, :name, :price_range, :min_message, :max_message, :event_message
    attr_accessor :price

    def initialize(attributes = {})
      @id = attributes[:id] || (self.index += 1)
      @name = attributes[:name]
      @price_range = attributes[:price_range]
      @min_message = attributes[:min_message]
      @max_message = attributes[:max_message]
      # FIXME: we need to set the price to a reasonable max, but it can't fluxuate
      @price = @price_range.max
      @event_message = nil
    end

    def event?
      !@event_message.blank?
    end

    def update_price!
      @price = price_range.rand
      @event_message = nil
      
      srand
      high_low = rand(HighLowRand)
      if high_low == 1
        @price *= HighLowRate
        @event_message = max_message
      elsif high_low == 0
        @price /= HighLowRate
        @event_message = min_message
      end
    end

    def to_h(with = {})
      {:id => id, :price => price.to_i}.merge(with)
    end
  end
end