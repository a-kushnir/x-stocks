# frozen_string_literal: true

lock '~> 3.17.1'

set :application, 'x-stocks'
set :repo_url, 'https://github.com/a-kushnir/x-stocks'

set :branch, :main
set :deploy_to, '/var/www/x-stocks'

# RVM
set :rvm_ruby_string, :local

# Migrations
set :migration_role, :db
set :migration_servers, -> { primary(fetch(:migration_role)) }
set :migration_command, 'db:migrate'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
