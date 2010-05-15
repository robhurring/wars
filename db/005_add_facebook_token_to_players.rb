class AddFacebookTokenToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :facebook_token, :string
  end

  def self.down
    remove_column :players, :facebook_token
  end
end