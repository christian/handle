class Emailer < ActionMailer::Base
  def anounce_user_as_a_watcher(recipients, subject, task = nil, change = nil)
    @subject = subject
    @recipients = recipients
    @from = 'handle@destravel-002.vm.brightbox.net'
    @sent_on = Time.now
    
    @body["task"] = task
    @body["change"] = change
    
    @headers = {}
  end
end
