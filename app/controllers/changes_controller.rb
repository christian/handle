class ChangesController < ApplicationController
  before_filter :get_task
  helper_method :current_project
  
  def index
    @changes = Change.all
  end
  
  def new
    @change = @task.changes.new
    @users = current_user.current_project_collaborators
    respond_to do |format|
      format.js {render :partial => 'changes/new', :change => @change} 
    end
  end
  
  def get_task_changes(old_task_params, new_task_params)
    task_changes = ''
    new_task_params.each_pair do |k, v|
      if old_task_params[k].to_s != v
        task_changes += "#{k}@@#{old_task_params[k]}>>#{v}||"
      end
    end
    task_changes
  end
  
  def create
    @change = Change.new(params[:change])
    @change.task_id = params[:task_id]
    @change.user_id = current_user.id
    @task = Task.find(params[:task_id])
    
    @change.task_changes = get_task_changes(@task.attributes, params[:change][:task_attributes])
    
    if @change.save && @task.update_attributes(params[:change][:task_attributes])
      wachers_emails = @task.watchers.collect(&:email) # (:conditions => ["id != ?", current_user.id]).
      project = @task.project
      send_email('anounce_user_as_a_watcher', wachers_emails, "Updated task: [#{project.name}] : [#{@task.title}]", @task, @change)
      # redirect to tasks if time is added from index or to task otherwise
      redirect_to :back
    else
      render :action => "new"
    end
  end
  
  def send_email(email_kind, recipients, subject, task = nil, change = nil)
    recipients.each do |recipient|
      Emailer.send(:"deliver_#{email_kind}", recipient, subject, task, change)
    end
    
    return if request.xhr?
    flash[:notice] = "Messages succesfully sent"
  end
  
  private
  def get_task
    @task = Task.find(params[:task_id])
  end
end
