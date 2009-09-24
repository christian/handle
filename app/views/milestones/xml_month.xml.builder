xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.chart do
  #xml.message "You can broadcast any message to chart from data XML file", :bg_color => "#FFFFFF", :text_color => "#000000"
  xml.series do    
    index = 0
    @milestones.each_pair do |k, v|
      xml.value k, :xid => index
      index += 1
    end
  end

  xml.graphs do
    #the gid is used in the settings file to set different settings just for this graph
    xml.graph :gid => 'milestones' do
      index = 0
      @milestones.each_pair do |k, v|
        xml.value v[0], :start => v[1], :xid => index
        index += 1
      end
    end 
  end
end
