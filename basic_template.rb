answer = ask("\n\nWekcome to basic template. Plz answer following questions\nDo you need sudo permittion to install gems?")
sudo = (answer == 'y' || answer == 'yes' || answer.empty?)

PROJECT_NAME = File.basename(root)

#====================
# PLUGINS
#====================

plugin 'exception_notifier', :git => "git://github.com/rails/exception_notification.git"
plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
plugin 'open_id_authentication',  :git => 'git://github.com/rails/open_id_authentication.git'

#====================
# GEMS
#====================

#gem 'mislav-will_paginate'


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

file 'config/database.yml', 
%{
development:
  adapter: mysql
  database: #{PROJECT_NAME}_development
  username: root
  password: 
  host: localhost
  encoding: utf8
  
test:
  adapter: mysql
  database: #{PROJECT_NAME}_test
  username: root
  password: 
  host: localhost
  encoding: utf8
  
production:
  adapter: mysql
  database: #{PROJECT_NAME}_production
  username: #{PROJECT_NAME}
  password: 
  host: localhost
  encoding: utf8
  socket: /var/lib/mysql/mysql.sock
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

rake("gems:install", :sudo => sudo)
rake("gems:unpack")

generate("authenticated", "user sessions --include-activation")

# ===============================
# USER OBSERVER after Authenticated generated
# ===============================

file 'config/environment.rb', File.readlines('config/environment.rb','w').join('\n').sub("Rails::Initializer.run do |config|", "Rails::Initializer.run do |config|\n\t#Added By Basic Template\n\tconfig.active_record.observers = :user_observer\n")

file 'app/models/user_observer.rb',
%q{class UserObserver < ActiveRecord::Observer
   def after_create(user)
    user.reload
    UserMailer.deliver_signup_notification(user)
   end
   
   def after_save(user)
    user.reload
    UserMailer.deliver_activation(user) if user.recently_activated?
   end
 end
}

answer = ask("\n\nWould you like me to generate a sample scaffold")
answer = (answer == 'y' || answer == 'yes' || answer.empty?)
if answer
 generate(:scaffold, "person", "name:string", "address:text", "age:integer")
 route "map.root :controller => 'people'"
else
 route "map.root :controller => 'sessions'"  
end

rake("db:create")
rake("db:migrate")


# ====================
# FINALIZE
# ====================

# This gem is helpful in development mode. This is not required in production. 
# So I am not going to add this gem in app specific gems list
#~ if sudo
 #~ run "sudo gem install ruby-debug"
#~ else
 #~ run "gem install ruby-debug"
#~ end

run "rm public/index.html"
run "touch public/stylesheets/screen.css"
run 'find . \( -type d -empty \) -and \( -not -regex ./\.git.* \) -exec touch {}/.gitignore \;'
git :init
git :add => "."
git :commit => "-a -m 'Initial project commit'"