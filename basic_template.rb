
#====================
# PLUGINS
#====================

plugin 'exception_notifier', :git => "git://github.com/rails/exception_notification.git"
plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
plugin 'open_id_authentication',  :git => 'git://github.com/rails/open_id_authentication.git'

#====================
# GEMS
#====================

gem 'mislav-will_paginate'
gem 'ruby-openid', :lib => 'openid'

#freeze!


#====================
# APP
#====================

file 'app/controllers/application_controller.rb', 
%q{class ApplicationController < ActionController::Base

  helper :all

  protect_from_forgery

  include ExceptionNotifiable

end
}

file 'app/helpers/application_helper.rb', 
%q{module ApplicationHelper
  def body_class
    "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
  end
end
}

file 'app/views/layouts/_flashes.html.erb', 
%q{<div id="flash">
  <% flash.each do |key, value| -%>
    <div id="flash_<%= key %>"><%=h value %></div>
  <% end -%>
  <% flash.clear %>
</div>
}

file 'app/views/layouts/application.html.erb', 
%q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <%= stylesheet_link_tag 'screen', :media => 'all', :cache => true %>
    <%= javascript_include_tag :defaults, :cache => true %>
  </head>
  <body>
    <%= render :partial => 'layouts/flashes' -%>
    <%= yield %>
  </body>
</html>
}

#====================
# INITIALIZERS
#====================

initializer 'action_mailer_configs.rb', 
%q{ActionMailer::Base.smtp_settings = {
    :address => "smtp.railsfactory.com",
    :port    => 25,
    :domain  => "railsfacroty.com"
}
ActionMailer::Base.delivery_method = :smtp
}


# ====================
# CONFIG
# ====================

capify!


# ====================
# RUN GENERATOR SCRIPTS
# ====================

rake("gems:install", :sudo => false)
rake("gems:unpack")

generate("authenticated", "user session")
generate(:scaffold, "person", "name:string", "address:text", "age:integer")

route "map.root :controller => 'people'"
route("map.signup  '/signup', :controller => 'users',   :action => 'new'")
route("map.login  '/login',  :controller => 'session', :action => 'new'")
route("map.logout '/logout', :controller => 'session', :action => 'destroy'")

rake("db:migrate")


# ====================
# FINALIZE
# ====================

# This gem is helpful in development mode. This is not required in production. 
# So I am not going to add this gem in app specific gems list
run "gem install ruby-debug"

run "rm public/index.html"
run "touch public/stylesheets/screen.css"
run 'find . \( -type d -empty \) -and \( -not -regex ./\.git.* \) -exec touch {}/.gitignore \;'
git :init
git :add => "."
git :commit => "-a -m 'Initial project commit'"