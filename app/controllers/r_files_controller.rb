class RFilesController < ApplicationController
  # must verify that current user has access to the specified file
  
  before_filter :login_required, :current_project
  helper_method :projects_collection, :current_project
  
  def index
    @r_files = current_project.files.all
  end
  def get_files
    if params[:project_id] == "-1"
      current_user.update_attributes(:current_project_id => -1)
      @files = @current_user.projects.collect(&:files)
    else
      @current_project = Project.find_by_id(params[:project_id])
      current_user.update_attributes(:current_project_id => @current_project.id)
      @files = @current_project.files
    end
    
    render :update do |page|
      page.replace_html 'files_list', :partial => 'files_list', :locals => {:files => @files}
      # set the current_project in user model
      # set the current_project in combo box
    end
  end
  
  def show
    @r_file = RFile.find(params[:id])
  end
  def new
    @r_file = RFile.new
  end
  def edit
    @r_file = RFile.find(params[:id])
  end
  def create
    @r_file = RFile.new(params[:r_file])
    if @r_file.save
      flash[:notice] = 'RFile was successfully created.'
      redirect_to r_files_path
    else
      render :action => "new"
    end
  end
  def update
    @r_file = RFile.find(params[:id])
    if @r_file.update_attributes(params[:r_file])
      flash[:notice] = 'RFile was successfully updated.'
      redirect_to r_files_path
    else
      render :action => "edit"
    end
  end
  def destroy
    @r_file = RFile.find(params[:id])
    @r_file.destroy
    redirect_to(r_files_url)
  end
end
