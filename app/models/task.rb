class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :asignee, :class_name => "User", :foreign_key => "assignee_id"
  belongs_to :opener, :class_name => "User", :foreign_key => "opener_id"
  
  has_many :watchings
  has_many :watchers, :through => :watchings, :source => :user 
  has_many :changes
  
  PRIORITIES  = [['Blocker', 5], ['High', 4], ['Medium', 3], ['Low', 2], ['Whishlist', 1]]
  STATUSES    = %w(Active Closed)
  KINDS       = %w(Bug Feature Story)
  RESOLUTIONS = ['In progress', 'Completed']
  
  after_save :add_watchers
  
  def time_spent
    changes.collect(&:minutes).sum
  end
  
  def add_watchers
    watchers << opener
    watchers << asignee if asignee.id != opener.id
  end
end
