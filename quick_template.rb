run "echo TODO > README"

gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
#~ rake "gems:install"

if yes?("Do you want to use RSpec?")
  plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git"
  plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git"
  generate :rspec
end

git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"

git :add => ".", :commit => "-m 'initial commit.'"

generate :nifty_layout

name = ask("What would you like the user to be called?")
generate :nifty_authentication, name
rake "db:migrate"
git :add => ".", :commit => "-m 'adding authentication'"

generate :controller, "home index"
route "map.root :controller => 'welcome'"
git :rm => "public/index.html"
git :add => ".", :commit => "-m 'adding home controller.'"