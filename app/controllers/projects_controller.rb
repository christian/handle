class ProjectsController < ApplicationController
  before_filter :check_is_superadmin, :only => [:new, :edit, :create, :update, :destroy]
  helper_method :current_project
  
  def index
    @projects = Project.all_project_user_works_for(current_user.id)
  end
  def show
    @project = Project.all_project_user_works_for(current_user.id).find(params[:id])
    @contributors = @project.users
  end
  def new
    @project = Project.new
    @users = User.all
    @milestones = @project.milestones.build
  end
  def edit
    @project = Project.find(params[:id])
    @users = User.all
  end
  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to(@project)
    else
      render :action => "new"
    end
  end
  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to(@project)
    else
      render :action => "edit"
    end
  end
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to(projects_url)
  end
  def get_users_for_project
    @project = current_user.projects.find(params[:id])
    @users_select = @project.users.collect{ |u| [u.name, u.id] }
    #@users_select.delete([current_user.name, current_user.id])
    if params[:mates] == "true"
      render :update do |page|
        page.replace_html "mates_list", :partial => "tasks/mates", :locals => {:users => Hash[*@users_select.flatten]}
      end
    end
  end
end
