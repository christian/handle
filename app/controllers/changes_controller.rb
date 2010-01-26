class ChangesController < ApplicationController
  before_filter :get_task, :except => :update
  helper_method :current_project, :users_collection
  
  def new
    @change = @task.changes.new
    @users = current_user.current_project_collaborators
    el = params[:type] == "index" ? "add_time_#{@task.id}" : "new_change"
    if request.xhr?
      render :update do |page|
        page.replace_html el, :partial => "new_change", 
                              :locals => {:change => @change, 
                                          :users => @users}
                                          #:users_select => @users_select}
      end
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
      render :update do |page|
        flash[:notice] = 'Change succesfully added.'
        @changes = @task.changes
        page.replace_html 'changes_list', :partial => 'tasks/changes_list'
        page.hide "error_messages"
        page.replace_html "change_notice", :partial => "shared/notice"
        flash[:notice] = nil
        page.show "change_notice"
        page.replace_html "new_change", ""
        page << '$("td[id^=add_time_]").html("");'
        
        page << '$("#for_day_change_' + @change.id.to_s + '").datePicker({startDate:\'1996-01-01\'}).click(click_date_picker).bind(\'dateSelected\', select_date);'
        page << '$("#time_spent_' + @change.id.to_s + '").click(click_time_spent_event_handler);'
        page << '$(".dp-choose-date").remove();'
      end
    else
      render :update do |page|
        page.replace_html "error_messages", error_messages_for('change', :header_tag => 'h3')
        page.show "error_messages"
      end
    end
  end
  
  def update
    @change = current_user.changes.find(params[:id])
    @change.update_attributes(params[:change])
    render :update do |page|
      page.replace_html "for_day_change_#{@change.id}", @change.for_day.to_s(:long)
      page.replace_html "time_spent_#{@change.id}", humanized_duration(@change.minutes)
    end
  end
  
  private
  def get_task
    @task = Task.find(params[:task_id])
  end
end
