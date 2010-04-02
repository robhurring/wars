module Wars
  class Fight < ActiveRecord::Base
    
    belongs_to :player
    
    validates_presence_of :player
    validates_presence_of :opponent
    
    def opponent
      if is_player?
        Player.find(opponent_id)
      else
        Npc.find(opponent_id)
      end
    end
    
  end
end