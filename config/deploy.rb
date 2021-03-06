# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'onTap'
set :repo_url, 'https://github.com/Orasi/onTap.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/ontap'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
#set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/aws.yml config/initializers/saml.rb)

# Default value for linked_dirs is []
set :linked_dirs, %w(public/photos tmp/pids log)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :rails_env, "production"

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :whenever_command, 'bundle exec whenever'
SSHKit.config.command_map[:whenever] = 'bundle exec whenever'

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
      within release_path do
        sudo "#{release_path}/bin/delayed_job restart RAILS_ENV=production"
        execute :whenever, '-i'
      end
    end
  end

  desc 'Clear Cache'
  task :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
        execute :rake, 'db:migrate'
      end
    end
  end

  desc 'Restart Delayed Job'
  task :restart_dj do
    on roles(:web), in: :sequence, wait: 5 do
      invoke 'delayed_job:restart'
    end
  end

  task :stop_dj do
    invoke 'delayed_job:stop'
  end

end
after 'deploy:restart', 'whenever:update_crontab'
after 'deploy:publishing', 'deploy:restart'

after 'deploy:publishing', 'deploy:clear_cache'
