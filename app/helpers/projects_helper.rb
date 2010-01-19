module ProjectsHelper
  def add_milestone_link(form_builder)
    link_to_function 'Add a milestone', :class => "ss_sprite ss_add" do |page|
      form_builder.fields_for :milestones, Milestone.new, :child_index => 'NEW_RECORD' do |f|
        html = render(:partial => 'milestones/form_fields', :locals => { :f => f })
        page << "$('#milestones').append('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()) );"
        page << <<-JS
          $(".span-6").each( function(index) {
            if ((index + 1) % 4 == 0 && index != 0) {
              $(this).addClass("last")
            }
            //alert(index);
          });
        JS
      end
    end
  end
  # Display the remove link for a child form
  def remove_milestone_link(form_builder)
    if form_builder.object.new_record?
      # If the milestone is a new record, we can just remove the div from the dom
      link_to_function("<strong>Remove milestone</strong>", "$(this).parent('.span-6').remove();", :class=>"ss_sprite ss_delete")
    else
      # However if it's a "real" record it has to be deleted from the database,
      # for this reason the new fields_for, accept_nested_attributes helpers give us 
      # _delete, a virtual attribute that tells rails to delete the child record.
      form_builder.hidden_field(:_delete) +
      link_to_function("<strong>Remove milestone</strong>", "$(this).parent('.span-6').hide(); $(this).prev().val('1')", :class=>"ss_sprite ss_delete")
    end
  end
end
