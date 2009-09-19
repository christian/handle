class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :asignee, :class_name => "User", :foreign_key => "asignee_id"
  belongs_to :opener, :class_name => "User", :foreign_key => "opener_id"
  
  has_many :changes
  
  PRIORITIES = [['Blocker', 5], ['High', 4], ['Medium', 3], ['Low', 2], ['Whishlist', 1]]
  STATUSES = %w(Active Closed)
  KINDS = %w(Bug Feature Story)
  RESOLUTIONS = ['In progress', 'Completed', 'Won\'t fix', 'Needs reivew']
  
  def time_spent
    changes.collect(&:minutes).sum
  end
end
