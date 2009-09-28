class AddProjectIdToFile < ActiveRecord::Migration
  def self.up
    add_column :r_files, :project_id, :integer
  end

  def self.down
    remove_column :r_files, :project_id
  end
end
