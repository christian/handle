class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, :email]
  end
  
  has_many :memberships, :dependent => :destroy
  has_many :projects, :through => :memberships
  has_many :changes
  has_many :tasks, :foreign_key => "assignee_id"
  
  belongs_to :current_project, :class_name => "Project", :foreign_key => "current_project_id"
  
  after_save :save_contributors
  attr_accessor :projects_ids
  def save_contributors
    unless projects_ids.nil?
      self.memberships.each do |m|
        m.destroy unless projects_ids.include?(m.project_id.to_s)
        projects_ids.delete(m.project_id.to_s)
      end
      
      projects_ids.each do |project_id|
        self.memberships.create(:project_id => project_id.to_i)
      end
      reload
      self.projects_ids = nil
    end
  end
  
  
  def self.ids_all_collaborators(current_user_id)
    u = User.find(current_user_id)
    if u.is_superadmin
      return User.all.collect(&:id)
    else
      ids = []
      u.projects.each do |p|
        ids += p.users(:select => :id).collect(&:id)
      end
      return ids.uniq
    end
  end
  
  named_scope :all_collaborators, lambda { |current_user_id| {
    :conditions => ["id in (?)", self.ids_all_collaborators(current_user_id)]
    }
  }
  
  def current_project_collaborators
    # shows the collaborators on the current project as a hash
    if self.current_project.nil?
      current_project = projects.first
      self.update_attributes(:current_project_id => projects.first.id)
    end
    self.current_project.users.collect{ |u| [u.name, u.id]}
  end
  
  # refactor as bellow
  def opened_tasks_count_for_project(proj_id)
    tasks.count(:conditions => ['status = "Active" AND project_id = ?', proj_id])
  end
  
  def closed_tasks_count_for_project(proj_id)
    tasks.count(:conditions => ['status = "Closed" AND project_id = ?', proj_id])
  end
  
  def priority_tasks_count_for_project(proj_id, priority)
    tasks.count(:conditions => ['priority = ? AND project_id = ?', proj_id, priority])
  end
  
  def opened_tasks_count
    tasks(:conditions => ['status = "Active"']).count
  end
  
  def total_tasks_count_for_project(proj_id)
    tasks.count(:conditions => ['project_id = ?', proj_id])
  end
  
  def time_spent_per_day(day=Date.today)
    changes.for_day_equals(day).inject(0) {|sum, change| sum + change.minutes }
  end

  def changes_today
    changes.count(:conditions => ["for_day = ?", Date.today])
  end

  def total_amount_of_work
    
  end
  
  private
  def map_openid_registration(registration)
    self.email = registration[:email] if email.blank?
    self.username = registration[:nickname] if username.blank?
  end
end
