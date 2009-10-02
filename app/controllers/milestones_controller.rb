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
  # def xml_month
  #   @milestones = Hash.new
  #   current_project.milestones.all(:order => "start_date").each do |milestone|
  #     @milestones[milestone.title] = [milestone.start_date.day, milestone.end_date.day]
  #   end
  #   respond_to do |format|
  #     format.xml {render :action => "xml_month.xml.builder", :layout => false}
  #   end
  # end
  def get_milestones
    @current_project = Project.find_by_id(params[:project_id])
    current_user.update_attributes(:current_project_id => @current_project.id) 
    @milestones = @current_project.milestones
    render :update do |page|
      page.replace_html 'milestones_list', :partial => 'milestones_list', :locals =>{:milestones => @milestones}
      # set the current_project in user model
      # set the current_project in combo box
    end
  end
  def show
    @milestone = current_project.milestones.find(params[:id])
  end
  def new
    @milestone = current_project.milestones.new
  end
  def edit
    @milestone = current_project.milestones.find(params[:id])
  end
  def create
    @milestone = current_project.milestones.new(params[:milestone])
    if @milestone.save
      flash[:notice] = 'Milestone succesfully created.'
      redirect_to(@milestone)
    else
      render :action => "new"
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
