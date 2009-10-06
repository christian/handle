/* Select an entire event, for when it spans multiple rows */
function select_event(ele, selected) {
  ele = $(ele);
  event_id = ele.readAttribute("event_id");
  events = $$('.event_'+event_id);
  events.each(function(event) {
    if (selected) event.setStyle({ backgroundColor: '#75CC28' });
    else event.setStyle({ backgroundColor: ele.readAttribute("color") });
  });
}