require 'fastercsv'
class StatisticsController < ApplicationController
  include ApplicationHelper
  before_filter :login_required, :current_project
  helper_method :projects_collection, :current_project
  
  def index
    @projects = current_user.projects
    @select_index = 0
    @projects.each_with_index do |p, i|
      @select_index = i if current_project.id == p.id
    end
    @start_date = params[:from] || Date.today.strftime("%Y-%m-%d")
    @end_date = params[:until] || Date.today.strftime("%Y-%m-%d")
    if current_user.is_superadmin
      @users = User.all
      @projects = Project.all
    else
      @users = User.all_collaborators(current_user.id)
      @projects = current_user.projects
    end
  end

  def users
    if current_user.is_superadmin
      @users = User.all
    else
      @users = User.all_collaborators(current_user.id)
    end
  end

  def projects
    if current_user.is_superadmin
      @projects = Project.all
    else
      @projects = current_user.projects
    end
  end

  def project_detail
    if current_user.is_superadmin
      @projects = Project.all
      @project = Project.find(params[:project_id])
    else
      @projects = current_user.projects
      @project = current_user.projects.find(params[:project_id])
    end
    
    @users = @project.users
  end
  
  def user_detail
    if current_user.is_superadmin
      @users = User.all
      @user = User.find(params[:user_id])
    else
      @users = User.all_collaborators(current_user.id)
      @user = User.all_collaborators(current_user.id).find(params[:user_id])
    end
    @projects = @user.projects
    @worked_on_tasks = Change.tasks_for_day_user(Date.today, @user.id)
    @date = Date.today
    
    week_stats
  end

  def week_stats(start_date=nil)
    if start_date.nil?
      beginning_of_week = Date.today.beginning_of_week 
    else
      beginning_of_week = start_date
    end
  
    @last_monday = beginning_of_week - 7.days
    @user = User.find(params[:user_id])
    @this_week = [*(beginning_of_week..beginning_of_week + 4.days)]
    @time_spent = Array.new
    @this_week.each do |day|
      @time_spent << @user.time_spent_per_day(day)
    end
  end
  
  def time_for_week
    start_day = Date.parse(params[:start_day])
    @last_monday = start_day - 7.days
    @next_monday = start_day + 7.days
    week_stats(start_day)
    render :update do |page|
      page.replace_html "weekly_graph", :partial => "weekly_graph"
      page.replace_html "prev_link", link_to_remote("&laquo; Previous week", :url => { :action => "time_for_week", :start_day => @last_monday, :user_id => @user.id })
      page.replace_html "next_link", link_to_remote("&laquo; Next week", :url => { :action => "time_for_week", :start_day => @next_monday, :user_id => @user.id })
    end
  end

  def time_for_day
    @user = User.find(params[:user_id])
    @date = Date.parse(params[:date])
    @worked_on_tasks = Change.tasks_for_day_user(@date, @user.id)
    render :update do |page|
      page.replace_html "day_stats", :partial => "day_stats"
    end
  end
  # => creates an xml for displaying time tracking for this week
  # def xml_user_this_week
  #   @user = User.find(params[:user_id])
  #   beginning_of_week = Date.today.beginning_of_week
  #   @this_week = [*(beginning_of_week..beginning_of_week + 4.days)]
  #   @time_spent = Array.new
  #   @this_week.each do |day|
  #     @time_spent << @user.time_spent_per_day(day)
  #   end
  #   
  #   respond_to do |format|
  #     format.xml {render :action => "user_detail.xml.builder", :layout => false}
  #   end
  # end
  
  def reports
    @start_date = params[:from] || Date.today.strftime("%Y-%m-%d")
    @end_date = params[:until] || Date.today.strftime("%Y-%m-%d")
  end
  
  def gen_report
    @projects = Project.all
    @start_date = Date.parse(params[:from])
    @end_date = Date.parse(params[:until])
    respond_to do |format| 
      format.csv {
        @outfile = "report.csv"
        
        csv_data = FasterCSV.generate do |csv|
          csv << [
          "Project",
          "Date",
          "Task",
          "Person",
          "Time",
          "Comment",
          "Billable",
          "PO"
          ]
          @projects.each do |project|
            (@start_date..@end_date).each do |day|
              project.changes.for_day_with_tasks(day).group_by(&:task).each do |task, changes|
                po = "PO: #{task.purchase_order}" unless task.purchase_order.nil?
                changes.each do |change|
                  csv << [
                    project.name,
                    day,
                    task.title,
                    change.user.name,
                    humanized_duration(change.minutes),
                    change.comment,
                    (task.billable == true ? "Yes" : "No"),
                    po.to_s
                  ]
                end
              end
            end
          end
        end

        send_data csv_data,
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{@outfile}"
      }
      format.html {
        
      }
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
