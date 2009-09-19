class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :memberships, :dependent => :destroy
  has_many :projects, :through => :memberships
  has_many :changes
  
  belongs_to :current_project, :class_name => "Project", :foreign_key => "current_project_id"
  
  def collaboratores
    current_project.users.collect{ |u| [u.name, u.id]}
  end
end
