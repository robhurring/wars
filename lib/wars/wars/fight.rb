module Wars
  class Fight < ActiveRecord::Base
    belongs_to :player
    validates_presence_of :player
    
    def npc
      @npc ||= Npc.find(npc_id)
    end
  end
end