class AddSimpleRolesUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_superadmin, :boolean
    add_column :users, :is_member, :boolean, :default => true
  end

  def self.down
    remove_column :users, :is_member
    remove_column :users, :is_superadmin
  end
end
