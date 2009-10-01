class AddTaskChangeToChange < ActiveRecord::Migration
  def self.up
    add_column :changes, :task_changes, :string
  end

  def self.down
    remove_column :changes, :task_changes
  end
end
