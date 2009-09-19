class AddRelationsToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :project_id, :integer
    add_column :tasks, :opener_id, :integer
    add_column :tasks, :assignee_id, :integer
  end

  def self.down
    remove_column :tasks, :assignee_id
    remove_column :tasks, :opener_id
    remove_column :tasks, :project_id
  end
end
