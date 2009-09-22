class Change < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  
  attr_accessor :reassing_user_id
  attr_accessor :days
  attr_accessor :hours

  accepts_nested_attributes_for :task
  
  before_save :convert_time_spent_to_minutes
  after_save :reassign_to_user
  
  def reassign_to_user
    task.assignee_id = reassing_user_id
    task.save
  end
  
  def convert_time_spent_to_minutes
    self.minutes = days.to_i * 1440 + hours.to_i * 60 + read_attribute(:minutes).to_i
  end
end
