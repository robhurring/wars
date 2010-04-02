module Wars
  class Event
    attr_reader :description, :condition, :action
    
    def initialize(attributes = {})
      @description = attributes[:description]
      @condition = attributes[:condition] || Proc.new{}
      @action = attributes[:action] || Proc.new{}
    end
    
    def apply(object)
      r = self.condition.call(object)
      Wars.log r
      if r
        object.instance_eval(&action)
      end
    end
  end
end