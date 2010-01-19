class AddBillableTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :billable, :boolean, :default => false
  end

  def self.down
    remove_column :tasks, :billable
  end
end
