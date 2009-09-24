class CreateWatchings < ActiveRecord::Migration
  def self.up
    create_table :watchings do |t|
      t.integer :task_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :watchings
  end
end
