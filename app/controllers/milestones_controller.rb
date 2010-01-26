class MilestonesController < ApplicationController
  before_filter :login_required, :current_project
  helper_method :projects_collection, :current_project
  
  def index
    @milestones = current_project.milestones.all :order => "start_at"
    
    @month = params[:month].nil? ? Time.now.month : params[:month].to_i 
    @year  = params[:year].nil? ? Time.now.year : params[:year].to_i 

    @shown_month = Date.civil(@year, @month)
    @event_strips = Milestone.event_strips_for_month(@shown_month)
  end
  def get_milestones
    @month = params[:month].nil? ? Time.now.month : params[:month].to_i 
    @year  = params[:year].nil? ? Time.now.year : params[:year].to_i 

    @shown_month = Date.civil(@year, @month)
    @event_strips = Milestone.event_strips_for_month(@shown_month)
    
    if params[:project_id] == "-1"
      current_user.update_attributes(:current_project_id => -1)
      @milestones = current_user.projects.collect(&:milestones)
    else
      @current_project = Project.find_by_id(params[:project_id])
      current_user.update_attributes(:current_project_id => @current_project.id) 
      @milestones = @current_project.milestones
    end
    
    render :update do |page|
      page.replace_html 'milestones_list', :partial => 'milestones_list', :locals =>{:milestones => @milestones}
    end
  end
  def show
    @milestone = current_project.milestones.find(params[:id])
  end
  def new
    @milestone = current_project.milestones.new
    render :update do |page|
      page.replace_html "new_milestone", :partial => "new_milestone", 
                                        :locals => {:milestone => @milestone }
    end
  end
  def edit
    @milestone = current_project.milestones.find(params[:id])
  end
  def create
    @milestone = current_project.milestones.new(params[:milestone])
    if @milestone.save
      render :update do |page|
        flash[:notice] = 'Milestone succesfully created.'
        @milestones = current_project.milestones
        page.replace_html 'milestones_list', :partial => 'milestones_list', :locals =>{:milestones => @milestones}
        page.hide "error_messages"
        page.replace_html "milestone_notice", :partial => "shared/notice"
        flash[:notice] = nil
        page.show "milestone_notice"
        page.replace_html "new_milestone", ""
      end
    else
      render :update do |page|
        page.replace_html "error_messages", error_messages_for('milestone', :header_tag => 'h3')
        page.show "error_messages"
      end
    end
  end
  def update
    @milestone = current_project.milestones.find(params[:id])
    if @milestone.update_attributes(params[:milestone])
      flash[:notice] = 'current_project.milestones was successfully updated.'
      redirect_to(@milestone)
    else
      render :action => "edit"
    end
  end
  def destroy
    @milestone = current_project.milestones.find(params[:id])
    @milestone.destroy
    redirect_to(milestones_url)
  end
end
