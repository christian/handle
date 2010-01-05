# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_host_for_email
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user#, :current_project
  
  protected
  
  private
  
  def login_required
    unless current_user
      redirect_to login_path
    end
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  
  def current_project
    @project ||= (current_user.current_project || current_user.projects.first)    
  end
  
  def current_project=(project)
    @project = project
  end
  
  def projects_collection
    projects = Hash[*current_user.projects.all.collect{|p| [p.name, p.id]}.flatten]
    projects.merge!({"All projects" => -1})
  end
  
  def users_collection
    users = Hash[*current_project.users.all.collect{|u| [u.name, u.id]}.flatten]
  end
  
  def check_is_superadmin
    unless current_user.is_superadmin
      render :text => "Not allowed."
    end
  end
  def set_host_for_email
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
