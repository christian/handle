class Change < ActiveRecord::Base
  default_scope :order => 'for_day'

  belongs_to :user
  belongs_to :task
  
  attr_accessor :reassing_user_id
  attr_accessor :text_time_spent

  accepts_nested_attributes_for :task
  
  before_save :convert_time_spent_to_minutes
  
  #validate 'valid_text_time_spent'
  validates_presence_of :for_day
  # validates_format_of /(\s)*([0-9]+d)?(\s)*([0-9]+h)?(\s)*/
  
  def convert_time_spent_to_minutes
    if text_time_spent == "Ex: 1d 14h 3m or 3h40m or 50m"
      self.minutes = 0
      return
    end
    unless text_time_spent.nil?
      text_time_spent.gsub(",", "")
      
      i = 0
      days = 0
      hours = 0
      mins = 0

      nos = text_time_spent.scan(/\d+/)
      kinds = text_time_spent.scan(/[dhm]+/)
      if nos.length != kinds.length
        self.minutes = 0
        return
      end

      kinds.each_with_index do |kind, i|
        case kind
        when "d"
          days = nos[i].to_i
        when "h"
          hours = nos[i].to_i
        when "m"
          mins = nos[i].to_i
        end
      end

      self.minutes = days * 480 + hours * 60 + mins
    else
      self.minutes = 0
    end
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
  
  protected
  def validate
    if text_time_spent != "" && !text_time_spent.nil?
      kinds = text_time_spent.scan(/[dhm]+/)
      possible_values = ["d","m","h"]
      begin
        if kinds.length < 1 && kinds.length > 3 then raise "1" end
        0.upto(kinds.length - 1) do |i|
          if !possible_values.include?(kinds[i])
            raise "2"
          end 
        end
      rescue Exception => ex
        errors.add_to_base "Invalid time spent."
      end
    end
  end
end
