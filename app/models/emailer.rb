class Emailer < ActionMailer::Base
  helper_method :humanized_duration
  
  def anounce_user_as_a_watcher(recipients, subject, task = nil, change = nil)
    @subject = subject
    @recipients = recipients
    @from = 'handle@destravel-002.vm.brightbox.net'
    @sent_on = Time.now
    
    @body["task"] = task
    @body["change"] = change
    
    @headers = {}
  end
  
  private
  def humanized_duration(duration)
    return if duration.nil?
    days    = duration / 1440
    hours   = (duration - (days * 1440)) / 60
    minutes = duration - (days * 1440 + hours * 60)
    days    = (days == 0) ? nil : "#{days} d"  
    hours   = (hours == 0) ? nil : "#{hours} h" 
    minutes = (minutes == 0) ? nil : "#{minutes} m" 
    duration_array = [days, hours, minutes]
    duration_array.delete(nil)
    return if duration_array.nil?
    return duration_array.join(", ") 
  end
end
