class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, :email]
  end
  
  has_many :memberships, :dependent => :destroy
  has_many :projects, :through => :memberships
  has_many :changes
  has_many :tasks, :foreign_key => "assignee_id"
  
  belongs_to :current_project, :class_name => "Project", :foreign_key => "current_project_id"
  
  def collaboratores
    if current_project.nil?
      current_project = projects.first
      self.update_attributes(current_project_id => projects.first.id)
    end
    current_project.users.collect{ |u| [u.name, u.id]}
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
  
  #
  #...
  #
  
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
