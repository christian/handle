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
