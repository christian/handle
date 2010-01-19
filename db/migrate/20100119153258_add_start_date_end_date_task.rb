class AddStartDateEndDateTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :start_date, :date
    add_column :tasks, :end_date, :date
  end

  def self.down
    remove_column :tasks, :end_date
    remove_column :tasks, :start_date
  end
end
