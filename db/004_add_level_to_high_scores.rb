class AddLevelToHighScores < ActiveRecord::Migration
  def self.up
    add_column :high_scores, :level, :integer
  end

  def self.down
    remove_column :high_scores, :level
  end
end