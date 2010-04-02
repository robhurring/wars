module Wars
  class HighScore < ActiveRecord::Base
    
    validates_presence_of :name
    validates_numericality_of :score
    validates_numericality_of :day
    
  end
end