class Change < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  
  attr_accessor :reassing_user_id
  attr_accessor :days
  attr_accessor :hours

  accepts_nested_attributes_for :task
  
  before_save :convert_time_spent_to_minutes
  # after_save :reassign_to_user
  # 
  # def reassign_to_user
  #   task.assignee_id = reassing_user_id
  #   task.save
  # end
  
  def convert_time_spent_to_minutes
    self.minutes = days.to_i * 1440 + hours.to_i * 60 + read_attribute(:minutes).to_i
  end
  
  def self.total_today # should be today for interval
    self.count(:conditions => ["for_day = ?", Date.today])
  end
  
  def self.tasks_for_day(day)
    self.all(:conditions =>["for_day = ?", day], :include => :task).collect(&:task)
  end
  
  def self.tasks_for_day_user(day, user_id)
    self.all(:conditions =>["for_day = ? AND user_id = ?", day, user_id], :include => :task).collect(&:task)
  end
  
  # reader
  # should refactor this in a helper or smth
  def task_changes
    unless read_attribute(:task_changes).nil? 
      unless read_attribute(:task_changes).empty? 
        changes = "<strong>Task changed</strong>: <ul>"
        read_attribute(:task_changes).split("||").each do |change|
          change.sub!("@@", ' from ')
          change.sub!(">>", ' to ')
          if change =~ /^assignee_id/
            #change.sub!("assignee_id", 'Person in charge')
            # get the numbers which represent the ids of the users
            # e.g. Person in charge from 1 to 5
            # we need to get 1 and 5
            change =~ /^assignee_id from (\d+) to (\d+)$/
            old_assignee = User.find($1.to_i, :select => :name)
            new_assignee = User.find($2.to_i, :select => :name)
            change = "assignee changed from #{old_assignee.name} to #{new_assignee.name}"
          end
          changes += "<li>" + change + "</li>"
        end
        changes += "</ul>"
        return changes
      end
    end
  end
end
