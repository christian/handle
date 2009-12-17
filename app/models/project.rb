class Project < ActiveRecord::Base
  default_scope :order => 'name ASC'
  
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  
  has_many :tasks, :dependent => :destroy
  has_many :milestones
  has_many :files, :class_name => "RFile"  
  
  attr_accessor :users_ids
  
  after_save :save_contributors
  
  def self.ids_all_projects_user_works_for(current_user_id)
    u = User.find(current_user_id)
    if u.is_superadmin
      return Project.all.collect(&:id)
    else
      return u.projects(:select => :id).collect(&:id).uniq
    end
  end
  
  named_scope :all_project_user_works_for, lambda { |current_user_id| {
    :conditions => ["id in (?)", self.ids_all_projects_user_works_for(current_user_id)]
    }
  }
  
  
  def self.projects_select
    self.all.collect {|p| [p.name, p.id]}
  end
  
  # def opened_tasks_count
  #   tasks(:conditions => ['status = "Active"']).count
  # end
  
  private
  def save_contributors
    unless users_ids.nil?
      #facilities_descriptions.delete("")
      #facilities_fees.delete("")
      self.memberships.each do |m|
        m.destroy unless users_ids.include?(m.user_id.to_s)
        users_ids.delete(m.user_id.to_s)
      end
      
      users_ids.each do |user_id|
        self.memberships.create(:user_id => user_id.to_i)
      end
      reload
      self.users_ids = nil
    end
  end
end
