class ConvertTaskEstimatedTimeToI < ActiveRecord::Migration
  def self.up
    remove_column :tasks, :estimated_time
    add_column :tasks, :estimated_time, :integer
  end

  def self.down
    remove_column :tasks, :estimated_time
    add_column :tasks, :estimated_time, :string
  end
end
