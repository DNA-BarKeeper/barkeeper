# frozen_string_literal: true

# Change these
server '128.176.195.75', port: 1694, roles: %i[web app db], primary: true

set :repo_url,        'git@github.com:SarahW91/gbol5.git'
set :application,     'gbol5'
set :user,            'sarah'
set :rbenv_ruby,      '2.6.7'
set :puma_threads,    [1, 5]
set :puma_workers,    2

# Always deploy currently checked out branch
set :branch, Regexp.last_match(1) if `git branch` =~ /\* (\S+)\s/m

# Rbenv setup
set :whenever_environment, fetch(:stage)
set :whenever_identifier, "#{fetch(:application)}_#{fetch(:stage)}"
set :whenever_variables, -> do
  "'environment=#{fetch :whenever_environment}" \
  "&rbenv_root=#{fetch :rbenv_path}'"
end

# Puma setup (Don't change these unless you know what you're doing)
set :pty,             false
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true # Change to false when not using ActiveRecord
set :puma_user, fetch(:user)

set :ssh_options, port: 1694, forward_agent: true, user: fetch(:user), keys: %w[/home/sarah/.ssh/id_rsa]

# Sidekiq setup
set :sidekiq_user => 'sarah' #user to run sidekiq as
set sidekiq_log: File.join(shared_path, 'log', 'sidekiq.log')
set sidekiq_config: File.join(shared_path, 'config', 'sidekiq.yml')

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{config/master.key}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        puts 'WARNING: HEAD is not the same as origin/master'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     invoke 'puma:restart'
  #   end
  # end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  # after  :finishing,    :restart
end

before 'deploy:assets:precompile', :symlink_config_files

desc 'Link shared files'
task :symlink_config_files do
  symlinks = {
    "#{shared_path}/config/master.key" => "#{release_path}/config/master.key"
  }

  on roles(:app) do
    execute symlinks.map { |from, to| "ln -nfs #{from} #{to}" }.join(' && ')
  end
end
