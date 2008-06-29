set :application, "db4442e2.fb.joyent.us"
set :project, "listens-facebook"
set :user, "db4442e2"

#set :rake, "/opt/local/bin/rake"
default_run_options[:pty] = true
set :repository,  "git@github.com:ryanlowe/listens-facebook.git"
set :scm, "git"
#set :scm_command, "/opt/local/bin/git"
set :branch, "origin/master"

set :deploy_to, "/home/#{user}/rails/#{project}"
#set :deploy_via, :remote_cache

# set the user that will start the mongrel instances
set :runner, user

role :app, application
role :web, application
role :db,  application, :primary => true

## CUSTOM TASKS

# server-side database.yml
before "deploy:setup", :db 
after "deploy:update_code", "db:symlink" 
namespace :db do 
   desc "symlink shared database.yml to release" 
   task :symlink do 
     run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
   end 
end