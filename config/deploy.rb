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

append :linked_files, 'config/credentials.yml.enc', 'config/master.key', 'config/secrets.yml'
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
