class ChangeDurationsInChangeModel < ActiveRecord::Migration
  def self.up
    remove_column :changes, :days
    remove_column :changes, :hours
  end

  def self.down
    add_column :changes, :hours, :integer
    add_column :changes, :days, :integer
  end
end
