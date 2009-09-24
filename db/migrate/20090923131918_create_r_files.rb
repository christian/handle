class CreateRFiles < ActiveRecord::Migration
  def self.up
    create_table :r_files do |t|
      t.string  :file_file_name
      t.integer :file_file_size
      t.string  :file_content_type
      t.integer :parent_id
      t.string  :type 
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :r_files
  end
end
