ActionController::Routing::Routes.draw do |map|
  map.resources :r_files

  map.resources :milestones, :collection => {:xml_month => :get, 
                                             :get_milestones => :get}

  map.resources :changes

  map.resources :projects

  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.register 'register', :controller => 'users', :action => 'new'
  
  map.statistics_xml_user_this_week 'statistics/users/:user_id/week_time', :controller => 'statistics', :action => 'xml_user_this_week'
  
  map.statistics_user_detail 'statistics/users/:user_id', :controller => 'statistics', :action => 'user_detail'
  map.statistics_project_detail 'statistics/projects/:project_id', :controller => 'statistics', :action => 'project_detail'
  map.statistics 'statistics', :controller => 'statistics', :action => 'index'
  
  map.resources :user_sessions
  map.resources :users, :has_many => :tasks
  map.resources :tasks, :collection => {:get_tasks => :get}, :member => {:add_watcher => :post, :remove_watcher => :post}
  map.root :controller => "tasks"
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  
end
