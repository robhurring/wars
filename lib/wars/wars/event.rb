module Wars
  class Event
    attr_reader :description, :condition, :action
    
    def initialize(attributes = {})
      @description = attributes[:description]
      @condition = attributes[:condition] || Proc.new{}
      @action = attributes[:action] || Proc.new{}
    end
    
    def apply(player)
      if self.condition.call(player)
        action.call(player)
      end
    end
  end
end