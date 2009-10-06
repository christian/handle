class UsersController < ApplicationController
  def index
    @users = User.all
  end
  def show
    @user = User.find(params[:id])
  end
  def new
    @user = User.new
  end
  def edit
    @user = User.find(params[:id])
  end
  def create
    @user = User.new(params[:user])
    @user.save do |result|
      if result
        flash[:notice] = 'Registration successful.'
        redirect_to root_url
      else
        render :action => "new"
      end
    end
  end
  def update
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    @user.save do |result|
      if result
        flash[:notice] = 'User was successfully updated.'
        redirect_to(@user)
      else
        render :action => "edit"
      end
    end
  end
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end
end
