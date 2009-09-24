class TasksController < ApplicationController
  before_filter :login_required, :current_project, :set_filter_session_vars
  helper_method :projects_collection, :current_project
  
  def index
    @user_of_tasks = params[:user_id] ? params[:user_id] : current_user.id
    @tasks = current_project.tasks.assignee_id_equals(@user_of_tasks).kind_equals(session[:tasks_kind]).priority_equals(session[:tasks_priority]).status_equals(session[:tasks_status]).resolution_equals(session[:tasks_resolution]).paginate(:per_page => 10, :page => params[:page])

    @projects = current_user.projects
    @select_index = 0
    @projects.each_with_index do |p, i|
      @select_index = i if current_project.id == p.id
    end
    if request.xhr?
      render :update do |page|
        page.replace_html 'tasks_list', :partial => 'tasks_list', :locals =>{:tasks => @tasks}
      end
    end
  end
  
  def get_tasks
    @current_project = Project.find_by_id(params[:project_id])
    current_user.update_attributes(:current_project_id => @current_project.id)
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
    @task.watchers << @watcher
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
  
  def show
    @task = Task.find(params[:id])
    @contributors = current_project.users
    @watchers = @task.watchers
  end

  def new
    @task = Task.new
    @users = current_project.users
    @users_select = @users.collect{ |u| [u.name, u.id] }
    @selected_index_user = 0
    @users_select.each_with_index { |u,i| (@selected_index_user = i+1) if u[1] == current_user.id }
    respond_to do |format|
      format.js {render :partial => 'new_task', :task => @task} 
    end
  end
  # def edit
  #   @task = Task.find(params[:id])
  # end
  def create
    @task = Task.new(params[:task])
    if @task.save
      flash[:notice] = 'Task was successfully created.'
      redirect_to(@task)
    else
      respond_to do |format|
        format.js {render :partial => 'new_task', :task => @task} 
      end
    end
  end
  # def update
  #   @task = Task.find(params[:id])
  #   if @task.update_attributes(params[:task])
  #     flash[:notice] = 'Task was successfully updated.'
  #     redirect_to(@task)
  #   else
  #     render :action => "edit"
  #   end
  # end
  def destroy
    @task = @project.tasks.find(params[:id])
    @task.destroy
    redirect_to(tasks_url)
  end
  
  private
  
  def current_project
    @project ||= current_user.current_project || current_user.projects.first    
  end
  def current_project=(project)
    @project = project
  end
  def projects_collection
    # Hash[*Project.all.collect{|p| [p.name, p.id]}.flatten]
    Project.all.collect{|p| [p.name, p.id]}.inject({}) do |result, element|
      result[element.first.to_sym] = element.last
      result
    end
  end
  def set_filter_session_vars
    session[:tasks_kind] ||= Task::KINDS  # what if there are no projects with ceratain attributes here
    session[:tasks_kind] = params[:tasks_kind] unless params[:tasks_kind].nil?

    session[:tasks_priority] ||= Task::PRIORITIES.collect{ |p| p[1] }
    session[:tasks_priority] = params[:tasks_priority] unless params[:tasks_priority].nil?

    session[:tasks_status] ||= Task::STATUSES
    session[:tasks_status] = params[:tasks_status] unless params[:tasks_status].nil?

    session[:tasks_resolution] ||= Task::RESOLUTIONS
    session[:tasks_resolution] = params[:tasks_resolution] unless params[:tasks_resolution].nil?
  end
end
