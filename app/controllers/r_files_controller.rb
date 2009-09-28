class RFilesController < ApplicationController
  # must verify that current user has access to the specified file
  
  before_filter :login_required, :current_project
  helper_method :projects_collection, :current_project
  
  def index
    @r_files = current_project.files.all
  end
  def get_files
    @current_project = Project.find_by_id(params[:project_id])
    current_user.update_attributes(:current_project_id => @current_project.id)
    @files = @current_project.files
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
  
  private
  
  def current_project
    @project ||= current_user.current_project #|| current_user.projects.first    
  end
  def current_project=(project)
    @project = project
  end
  def projects_collection
    # Hash[*Project.all.collect{|p| [p.name, p.id]}.flatten]
    @select_index = 0
    i = 0
    Project.all.collect{|p| [p.name, p.id]}.inject({}) do |result, element|
      i += 1
      @select_index = i if element.last == current_project.id
      result[element.first.to_sym] = element.last
      result
    end
#    raise @select_index.inspect
  end
  
end
