class StatisticsController < ApplicationController
  before_filter :login_required, :current_project
  helper_method :projects_collection, :current_project
  
  def index
    @projects = current_user.projects
    @select_index = 0
    @projects.each_with_index do |p, i|
      @select_index = i if current_project.id == p.id
    end
    
    @users = User.all
  end

  def users
    @users = User.all
  end

  def projects
    @projects = Project.all
  end

  def project_detail
    @projects = Project.all
    @project = Project.find(params[:project_id])
    
    @users = @project.users
  end
  
  def user_detail
    @users = User.all
    @user = User.find(params[:user_id])
    @projects = @user.projects
  end

  # => creates an xml for displaying time tracking for this week
  def xml_user_this_week
    @user = User.find(params[:user_id])
    beginning_of_week = Date.today.beginning_of_week
    @this_week = [*(beginning_of_week..beginning_of_week + 4.days)]
    @time_spent = Array.new
    @this_week.each do |day|
      @time_spent << @user.time_spent_per_day(day)
    end
    
    respond_to do |format|
      format.xml {render :action => "user_detail.xml.builder", :layout => false}
    end
  end

  private
  
  def current_project
    @project ||= Project.first    
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
end
