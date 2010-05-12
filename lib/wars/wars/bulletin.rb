module Wars
  class Bulletin < ActiveRecord::Base
    belongs_to :player
    
    validates_presence_of :message
    validates_length_of :message, :within => 1..Data::BulletinLength, :on => :create, :message => "must be between 1-#{Data::BulletinLength} chars."

    named_scope :recent, {:limit => 25, :order => 'created_at DESC'}

    def before_validation
      write_attribute(:message, Sanitize.clean(self.message)) if defined? Sanitize
      write_attribute(:message, self.message[0...Data::BulletinLength])
    end
  end
end