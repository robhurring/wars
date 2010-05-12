class CreateBulletinTables < ActiveRecord::Migration
  def self.up
    create_table :bulletins, :force => true do |t|
      t.string :name
      t.string :ip
      t.string :message, :limit => 140
      t.boolean :checked, :default => false
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :bulletins
  end
end