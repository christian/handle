class AddForDayToChange < ActiveRecord::Migration
  def self.up
    add_column :changes, :for_day, :date
  end

  def self.down
    remove_column :changes, :for_day
  end
end
