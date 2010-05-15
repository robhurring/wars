class AddDeathDescriptionToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :death_description, :text
  end

  def self.down
    remove_column :players, :death_description
  end
end