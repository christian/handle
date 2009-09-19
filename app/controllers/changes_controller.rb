class ChangesController < ApplicationController
  before_filter :get_task
  helper_method :current_project
  
  def index
    @changes = Change.all
  end
  
  def show
    @change = Change.find(params[:id])
  end

  def new
    @change = @task.changes.new
    @users = current_user.collaboratores
    respond_to do |format|
      format.js {render :partial => 'changes/new', :change => @change} 
    end
  end
  
  def edit
    @change = Change.find(params[:id])
  end
  
  def create
    @change = Change.new(params[:change])
    @change.task_id = params[:task_id]
    @change.user_id = current_user.id
    if @change.save
      flash[:notice] = 'Change was successfully created.'
      # redirect to tasks if time is added from index or to task otherwise
      redirect_to :back
    else
      render :action => "new"
    end
  end
  
  def update
    @change = Change.find(params[:id])
    if @change.update_attributes(params[:change])
      flash[:notice] = 'Change was successfully updated.'
      redirect_to(@change)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @change = Change.find(params[:id])
    @change.destroy
    redirect_to(changes_url)
  end
  
  private
  def get_task
    @task = Task.find(params[:task_id])
  end
end
