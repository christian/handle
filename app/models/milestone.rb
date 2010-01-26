class Milestone < ActiveRecord::Base
  belongs_to :project
  has_many :tasks
  
  has_event_calendar
  
  validates_presence_of :name, :start_at, :end_at
  
  default_scope :order => 'start_at'
end
