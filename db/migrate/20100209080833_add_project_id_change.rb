class AddProjectIdChange < ActiveRecord::Migration
  def self.up
    add_column :changes, :project_id, :integer
    
    Change.all.each do |change|
      if change.task
        change.update_attributes(:project_id => change.task.project_id)
      end
    end
  end

  def self.down
    remove_column :changes, :project_id
  end
end
