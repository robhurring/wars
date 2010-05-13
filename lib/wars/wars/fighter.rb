module Wars
  # some methods for fighting / etc.
  module Fighter
    DamageVariable = 20
    EscapeRate = 3
    
    # Override these
    def strength; 0 end
    def defense; 0 end
    
    # returns the damage to opponent
    def attack(opponent)
      amplifier = (rand * DamageVariable).ceil
      dmg = 0
      if amplifier + strength > opponent.defense || amplifier == DamageVariable
        dmg = strength * (rand + 0.5)
        dmg -= opponent.defense
        dmg = 1 if dmg < 0
      end
      dmg.ceil
    end
    
    # returns true/false if you got away
    def run(opponent)
      rand(EscapeRate) == 0
    end    
  end
end