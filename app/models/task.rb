class Task < ActiveRecord::Base
  default_scope :order => 'created_at DESC'
    
  belongs_to :project
  belongs_to :asignee, :class_name => "User", :foreign_key => "assignee_id"
  belongs_to :opener, :class_name => "User", :foreign_key => "opener_id"
  
  has_many :watchings
  has_many :watchers, :through => :watchings, :source => :user 
  has_many :changes
  
  validates_presence_of :title
#  validates_uniqueness_of :title, :on => :create, :message => "must be unique"  
  
  attr_accessor :estimated_days
  attr_accessor :estimated_hours
  attr_accessor :estimated_minutes
  
  PRIORITIES  = [['Blocker', 5], ['High', 4], ['Medium', 3], ['Low', 2], ['Whishlist', 1]]
  STATUSES    = %w(Active Closed)
  KINDS       = %w(Bug Feature Story)
  RESOLUTIONS = ['In progress', 'Completed']
  
  ORDER       = ['title', 'priority', 'status', 'resolution', 'kind']
  ORDER_TYPE  = ['asc', 'desc']
  
  named_scope :order, lambda { |order, order_type| {
      :order => "#{order} #{order_type}"
    }
  }
  
  after_save :add_watchers
  before_save :convert_time_spent_to_minutes
  
  def time_spent
    changes.collect(&:minutes).sum
  end
  
  def add_watchers
    if (watchers(:select => "id").collect(&:id) & [opener.id, asignee.id]) == []
      watchers << opener 
      watchers << asignee if asignee.id != opener.id
    end
  end
  
  def convert_time_spent_to_minutes
    self.estimated_time = estimated_days.to_i * 1440 + estimated_hours.to_i * 60 + read_attribute(:estimated_time).to_i
  end
end
