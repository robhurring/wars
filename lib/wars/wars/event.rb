module Wars
  class Event
    attr_reader :description, :condition, :action
    
    def initialize(attributes = {})
      @description = attributes[:description]
      @condition = attributes[:condition] || Proc.new{}
      @action = attributes[:action] || Proc.new{}
    end
    
    def apply(object)
      if self.condition.call(object)
        object.instance_eval(&action)
      end
    end
  end
end