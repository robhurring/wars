class CreateFightTables < ActiveRecord::Migration
  def self.up
    create_table :fights, :force => true do |t|
      t.integer :player_id
      t.integer :opponent_id
      t.boolean :is_player, :default => false
      t.timestamps
    end
    add_column :players, :days_without_incident, :integer
  end

  def self.down
    remove_column :players, :days_without_incident
    drop_table :fights
  end
end