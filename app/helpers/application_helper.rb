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
    menu = [['Tasks', tasks_path],
            # ['Messages', ''],
            ['Files', r_files_path],
            ['Milestones', milestones_path],
            #['My todos', ''],
            ['Projects', projects_path],
            ['Users', users_path],
            ['Statistics', statistics_from_until_path(Date.today.strftime("%Y-%m-%d"), Date.today.strftime("%Y-%m-%d"))]]
    menu.each do |menu_item|
      m += ' <li>' +  link_to(menu_item.first, menu_item.last, :class => (controller.controller_name == menu_item.first.downcase ? 'selected' : '')) + '</li>'
    end
    m += '</ul>'

    #   <li><%= link_to 'Specs', '' %></li>
    #   <li><%= link_to 'Projects', projects_path %></li>
    #   <li><%= link_to 'Users', users_path %></li>
    #   <li><%= link_to 'Statistics', '' %></li>
    # </ul>
  end
end
