class ChangesController < ApplicationController
  before_filter :get_task, :except => :update
  helper_method :current_project, :users_collection
  
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
    @task.touch
    
    @change.task_changes = get_task_changes(@task.attributes, params[:change][:task_attributes])
    
    if @change.save && @task.update_attributes(params[:change][:task_attributes])
      send_email_task_was_changed(@task, @change)
      redirect_to :back
    else
      render :action => "new"
    end
  end
  
  def update
    @change = current_user.changes.find(params[:id])
    @change.update_attributes(params[:change])
    render :update do |page|
      page.replace_html "for_day_change_#{@change.id}", @change.for_day.to_s(:long)
    end
  end
  
  private
  def get_task
    @task = Task.find(params[:task_id])
  end
end
