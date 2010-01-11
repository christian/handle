# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def humanized_duration(duration)
    return if duration.nil?
    days    = duration / 1440
    hours   = (duration - (days * 1440)) / 60
    minutes = duration - (days * 1440 + hours * 60)
    days    = (days == 0) ? nil : "#{days} d"  
    hours   = (hours == 0) ? nil : "#{hours} h" 
    minutes = (minutes == 0) ? nil : "#{minutes} m" 
    duration_array = [days, hours, minutes]
    duration_array.delete(nil)
    return if duration_array.nil?
    return duration_array.join(", ") 
  end
  
  def menu
    m = '<ul class="tabs">'
    # ['text on tab +  visual effects', 'path', 'controller for hightlight']
    
    # <span class="ss_sprite ss_layout_edit ">&nbsp; Tasks</span>
    # <span class="ss_sprite ss_folder_page ">&nbsp; Files</span>
    # <span class="ss_sprite ss_calendar ">&nbsp; Milestones</span>
    # <span class="ss_sprite ss_briefcase">&nbsp; Projects</span>
    # <span class="ss_sprite ss_group">&nbsp; Users</span>
    # <span class="ss_sprite ss_chart_bar">&nbsp; Statistics</span>
    menu = [['&nbsp; Tasks &nbsp;', tasks_path, 'tasks'],
            ['&nbsp; Files &nbsp;', r_files_path, 'r_files'],
            ['&nbsp; Milestones &nbsp;', milestones_path, 'milestones'],
            ['&nbsp; Projects &nbsp;', projects_path, 'projects'],
            ['&nbsp; Users &nbsp;', users_path, 'users'],
            ['&nbsp; Statistics &nbsp;', statistics_from_until_path(Date.today.strftime("%Y-%m-%d"), Date.today.strftime("%Y-%m-%d")), 'statistics']]
    menu.each do |menu_item|
      m += ' <li>' +  link_to(menu_item.first, menu_item[1], :class => (controller.controller_name == menu_item[2].downcase ? 'selected' : '')) + '</li>'
    end
    m += '</ul>'
  end
end
