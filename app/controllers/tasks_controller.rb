class TasksController < ApplicationController
  before_filter :login_required, :current_project, :set_filter_session_vars#, :projects_collection
  helper_method :projects_collection, :current_project
  
  def filter_tasks
    @user_of_tasks = params[:user_id] ? params[:user_id] : current_user.id
    if params[:project_id].nil?
      # view certain users tasks
      @tasks_for = params[:user_id].nil? ? "My" : User.find(params[:user_id]).name 
      @tasks = current_project.tasks.assignee_id_equals(@user_of_tasks).
                              kind_equals(session[:tasks_kind]).
                              priority_equals(session[:tasks_priority]).
                              status_equals(session[:tasks_status]).
                              resolution_equals(session[:tasks_resolution]).
                              order(session[:tasks_order], session[:tasks_order_type]).
                              paginate(:per_page => 10, :page => params[:page])
    else
      # view certain project tasks
      @project = Project.find(params[:project_id])
      @tasks_for = @project.name
      @tasks = @project.tasks.kind_equals(session[:tasks_kind]).
                              priority_equals(session[:tasks_priority]).
                              status_equals(session[:tasks_status]).
                              resolution_equals(session[:tasks_resolution]).
                              order(session[:tasks_order], session[:tasks_order_type]).
                              paginate(:per_page => 10, :page => params[:page])
    end

  end
  
  def index
    filter_tasks
    if request.xhr?
      render :update do |page|
        page.replace_html 'tasks_list', :partial => 'tasks_list', :locals =>{:tasks => @tasks}
      end
    end
  end
  
  def get_tasks
    @current_project = Project.find_by_id(params[:project_id])
    current_user.update_attributes(:current_project_id => @current_project.id)
    session[:current_project_select_index] = current_user.id
    @tasks = @current_project.tasks.find_all_by_assignee_id(current_user.id).paginate(:per_page => 10, :page => params[:page])
    render :update do |page|
      page.replace_html 'tasks_list', :partial => 'tasks_list', :locals =>{:tasks => @tasks}
      # set the current_project in user model
      # set the current_project in combo box
    end
  end
  
  def add_watcher
    @task = Task.find(params[:id])
    @watcher = User.find(params[:watcher_id])
    unless @task.watchers(:select => :id).collect(&:id).include?(@watcher.id)
      @task.watchers << @watcher
    end
    show
    render :update do |page|
      page.replace_html 'watchers', :partial => 'watchers', :locals => {:watchers => @watchers, :contributors => @contributors, :task => @task}
    end
  end
  
  def remove_watcher
    Watching.find_by_task_id_and_user_id(params[:id], params[:user_id]).destroy
    show
    render :update do |page|
      page.replace_html 'watchers', :partial => 'watchers', :locals => {:watchers => @watchers, :contributors => @contributors, :task => @task}
    end
  end
  
  def close
    filter_tasks
    @task = Task.find(params[:task_id])
    @task.update_attributes(:status => :close)
    render :update do |page|
      page.replace_html 'tasks_list', :partial => {:tasks => @tasks}
    end
  end
  
  def show
    @task = Task.find(params[:id])
    @watchers = @task.watchers
    @contributors = current_project.users#.delete(@watchers)
  end

  def new
    @task = Task.new
    @users = current_project.users
    @users_select = @users.collect{ |u| [u.name, u.id] }
    
    respond_to do |format|
      format.js {render :partial => 'new_task', :task => @task} 
    end
  end

  def create
    @task = Task.new(params[:task])
    if @task.save
      flash[:notice] = 'Task was successfully created.'
      redirect_to(@task)
    else
      #render :action => "new_task"
      redirect_to "/changes/new?height=540&width=520&inlineId=hiddenModalContent&task_id=37"
    end
  end

  private

  def set_filter_session_vars
    session[:tasks_kind] ||= Task::KINDS  # what if there are no projects with ceratain attributes here
    session[:tasks_kind] = params[:tasks_kind] unless params[:tasks_kind].nil?

    session[:tasks_priority] ||= Task::PRIORITIES.collect{ |p| p[1].to_s }
    session[:tasks_priority] = params[:tasks_priority] unless params[:tasks_priority].nil?

    session[:tasks_status] ||= Task::STATUSES.dup.delete("Active")
    session[:tasks_status] = params[:tasks_status] unless params[:tasks_status].nil?

    session[:tasks_resolution] ||= Task::RESOLUTIONS.dup.delete("In progress")
    session[:tasks_resolution] = params[:tasks_resolution] unless params[:tasks_resolution].nil?
    
    session[:tasks_order] ||= Task::ORDER[2]
    session[:tasks_order] = params[:tasks_order] unless params[:tasks_order].nil?
    
    session[:tasks_order_type] ||= Task::ORDER_TYPE[1]
    session[:tasks_order_type] = params[:tasks_order_type] unless params[:tasks_order_type].nil?
  end
end
