class Emailer < ActionMailer::Base
  def anounce_user_as_a_watcher(recipient, subject, message, sent_at = Time.now)
    @subject = subject
    @recipients = recipient
    @from = 'no-reply@destravel-002.vm.brightbox.net'
    @sent_on = sent_at
    
    @body["task"] = task
    @body["change"] = change
    
    @headers = {}
  end
end
