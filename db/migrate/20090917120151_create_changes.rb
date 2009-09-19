class CreateChanges < ActiveRecord::Migration
  def self.up
    create_table :changes do |t|
      t.text :comment
      t.integer :days
      t.integer :hours
      t.integer :minutes
      t.integer :user_id
      t.integer :task_id
      t.timestamps
    end
  end

  def self.down
    drop_table :changes
  end
end
