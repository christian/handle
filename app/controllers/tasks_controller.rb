class TasksController < ApplicationController
  before_filter :login_required, :current_project, :set_filter_session_vars#, :projects_collection
  helper_method :projects_collection, :current_project
  
  def filter_tasks
    # handle search
    if !params[:search].nil? && params[:search] != "" && params[:search] != "Search: id or keywords + ENTER"
      if params[:search] == ""
        @tasks = []
      end
      if params[:search] =~ /^\d+$/
        @tasks = Task.all(:conditions => ["id = ? AND project_id IN (?)", params[:search].to_i, current_user.projects.collect(&:id)]).paginate(:per_page => 10, :page => params[:page])
      else
        @tasks = Task.search(params[:search], :with => {:project_id => current_user.projects.collect(&:id)}).paginate(:per_page => 10, :page => params[:page])
      end
      return
    end
    
    # setup user
    unless params[:user_id].nil?
      session[:tasks_user_id] = params[:user_id]
    else
      if session[:tasks_user_id] == nil
        session[:tasks_user_id] = current_user.id
      end
    end
    
    if current_user.current_project_id == -1
      # show all tasks for all projects
      session[:tasks_user_id] = current_user.id if session[:tasks_user_id] == "-1"
      what_tasks = Task.assignee_id_like_any(User.ids_all_collaborators(session[:tasks_user_id]))
    elsif session[:tasks_user_id].to_i == -1 and current_user.current_project_id > 0
      # show all tasks for one project
      what_tasks = Task.project_id_equals(current_user.current_project_id)
    elsif session[:tasks_user_id].to_i > 0 and current_user.current_project_id == -1
      # show all tasks for one user
      what_tasks = Task.assignee_id_equals(session[:tasks_user_id])
    elsif session[:tasks_user_id].to_i > 0 and current_user.current_project_id > 0
      # show all tasks for a user on one project
      what_tasks = Task.assignee_id_equals(session[:tasks_user_id]).
                        project_id_equals(current_user.current_project_id)
    else
      raise "shouldn't get here"
    end
    
    #filter the tasks
    @tasks = what_tasks.kind_equals(session[:tasks_kind]).
                        priority_equals(session[:tasks_priority]).
                        status_equals(session[:tasks_status]).
                        resolution_equals(session[:tasks_resolution]).
                        paginate(:per_page => 10, :page => params[:page])
                        
                        #order(session[:tasks_order], session[:tasks_order_type]).
                        
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
    current_user.update_attributes!(:current_project_id => params[:project_id]) unless params[:project_id].nil?
    filter_tasks
    render :update do |page|
      page.replace_html 'tasks_list', :partial => 'tasks_list', :locals =>{:tasks => @tasks}
      page << "m = $(\"#mates_list\").is(':visible');"
      if params[:project_id] == "-1"
        page.hide "project_tasks_link"
        page.hide "team_mates_tasks_link"
      else
        page.show "project_tasks_link"
        page.show "team_mates_tasks_link"
        page.replace_html "mates_list", :partial => "tasks/mates", :locals => {:users => users_collection}
        page << <<-js
                 // kind of ugly :)
                 if (m) {
                    $("#mates_list").show();
                 }
              js
        
      end
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
    @task = Task.find(params[:id])
    @change = Change.new(:user_id => current_user.id,
                         :for_day => Date.today,
                         :task_changes => "status@@#{@task.status}>>Closed||
                                           resolution@@#{@task.resolution}>>Completed||")
    @change.task = @task
    
    if @task.update_attributes(:status => "Closed") && @change.save()
      send_email_task_was_changed(@task, @change)
      filter_tasks
      render :update do |page|
        page.replace_html 'tasks_list', :partial => 'tasks_list', :locals => {:tasks => @tasks}
      end
    end
  end
  
  def show
    @task = Task.find(params[:id])
    @watchers = @task.watchers
    @contributors = current_project.users#.delete(@watchers)
  end

  def init_new_task
    @task = Task.new
    @users = current_project.users
    @users_select = @users.collect{ |u| [u.name, u.id] }
  end

  def new
    init_new_task    
    if request.xhr?
      render :update do |page|
        page.replace_html "new_task", :partial => "new_task", 
                                      :locals => {:task => @task, 
                                                  :users => @users,
                                                  :users_select => @users_select}
      end
    else
      redirect_to :action => :index
    end
  end
  
  #TODO: refactor to use RJS
  def create
    @task = Task.new(params[:task])
    if @task.save
      send_email('create_a_new_task', @task.asignee, "New task created: #{@task.project.name} : #{@task.title}", @task)
      flash[:notice] = "Task was successfully created. Email sent to #{@task.asignee.name}."
      if params[:add_another] == "1"
        init_new_task
#        filter_tasks
        render :update do |page|
          page << "$('form :input').val(\"\");"
          page.hide "error_messages"
          page.replace_html "task_notice", :partial => "shared/notice"
          page.show "task_notice"
          page.replace_html 'tasks_list', :partial => 'tasks_list', :locals =>{:tasks => @tasks}
          page.replace_html "new_task", :partial => "new_task", 
                                        :locals => {:task => @task, 
                                                    :users => @users,
                                                    :users_select => @users_select}
        end
      else
        render :update do |page|
          page.redirect_to @task
        end
      end
    else
      render :update do |page|
        page.replace_html "error_messages", error_messages_for('task', :header_tag => 'h3')
        page.show "error_messages"
      end
    end
  end

  def update
    @task = Task.find(params[:id])
    @task.update_attributes(params[:task])
    respond_to do |format| 
      format.js { render :text => @task.send(params[:wants]) }      
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
