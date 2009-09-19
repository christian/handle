class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.string :estimated_time
      t.integer :priority
      t.string :kind
      t.string :status
      t.string :resolution

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
