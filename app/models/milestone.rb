class Milestone < ActiveRecord::Base
  belongs_to :project
  has_many :tasks
  
  has_event_calendar
  
  default_scope :order => 'start_at'
end
