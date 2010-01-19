class AddPoMilestoneTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :purchase_order, :string
    add_column :tasks, :milestone_id, :integer
  end

  def self.down
    remove_column :tasks, :milestone_id
    remove_column :tasks, :purchase_order
  end
end
