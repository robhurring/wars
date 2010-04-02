class CreateBaseTables < ActiveRecord::Migration
  def self.up
    create_table :players, :force => true do |t|
      t.string :name
      t.string :password
      t.integer :life
      t.integer :cash
      t.integer :debt
      t.integer :bank
      t.integer :location_id
      t.integer :day
      t.integer :days_in_debt
      t.text :equipment
      t.text :products
      t.timestamps
    end
    create_table :high_scores, :force => true do |t|
      t.string :name
      t.integer :score
      t.integer :day
      t.string :reason
      t.timestamps
    end
  end

  def self.down
    drop_table :high_scores
    drop_table :players
  end
end