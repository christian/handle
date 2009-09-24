class RFilesController < ApplicationController
  def index
    @r_files = RFile.all
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
      redirect_to(@r_file)
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
