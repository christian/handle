class ProjectsController < ApplicationController
  before_filter :check_is_superadmin, :only => [:new, :edit, :create, :update, :destroy]
  
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
end
