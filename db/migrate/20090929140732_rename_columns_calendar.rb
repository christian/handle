class RenameColumnsCalendar < ActiveRecord::Migration
  def self.up
    rename_column :milestones, :start_date, :start_at 
    rename_column :milestones, :end_date, :end_at
    rename_column :milestones, :title, :name
  end

  def self.down
    rename_column :milestones, :name, :title
    rename_column :milestones, :end_at, :end_date
    rename_column :milestones, :start_at, :start_date
  end
end
