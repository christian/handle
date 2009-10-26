
## NOT USED !!!!

# xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
# xml.chart do
#   #xml.message "You can broadcast any message to chart from data XML file", :bg_color => "#FFFFFF", :text_color => "#000000"
#   xml.series do    
#     @this_week.each_with_index do |day, index|
#       xml.value day.strftime("%a"), :xid => index
#     end
#   end
# 
#   xml.graphs do
#     #the gid is used in the settings file to set different settings just for this graph
#     xml.graph :gid => 'population' do
#       @time_spent.each_with_index do |time, index|
#         xml.value time / 60, :xid => index, :description => humanized_duration(time)
#       end
#     end #:color => "#ff43a8", :gradient_fill_colors => "#960040,#ff43a8", 
#     
#     xml.graph :gid => 'minutes' do
#       @time_spent.each_with_index do |time, index|
#         val = (time % 60 / 60.0).to_f
#         xml.value val, :xid => index, :description => humanized_duration(time)
#       end
#     end #:color => "#00C3C6", :gradient_fill_colors => "#009c9d,#00C3C6", 
#     
#   end
# end
