class CreateFightTables < ActiveRecord::Migration
  def self.up
    create_table :fights, :force => true do |t|
      t.integer :player_id
      t.integer :npc_id
      t.integer :npc_damage_taken, :default => 0
      t.timestamps
    end
    add_column :players, :days_without_incident, :integer
  end

  def self.down
    remove_column :players, :days_without_incident
    drop_table :fights
  end
end