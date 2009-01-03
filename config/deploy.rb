set :application, "giwiki"
set :repository,  "git@github.com:railsrumble/br-labs.git"
set :branch, "master"

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }
set :user, "deploy"
set :runner, "deploy"

set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/giwiki"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

role :app, "66.246.75.13"
role :web, "66.246.75.13"
role :db,  "66.246.75.13", :primary => true

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
task :after_update_code do
  %w{uploads}.each do |share|
    run "ln -s #{shared_path}/public/#{share} #{release_path}/public/#{share}"
  end
  run "ln -s #{shared_path}/pages #{release_path}/pages"
  run "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
end
