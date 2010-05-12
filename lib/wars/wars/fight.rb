module Wars
  class Fight < ActiveRecord::Base
    belongs_to :player
    validates_presence_of :player
    
    def npc
      @npc ||= begin
        npc = Npc.find(npc_id).dup
        npc.life -= npc_damage_taken
        npc
      end
    end
  end
end