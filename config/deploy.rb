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

append :linked_files, 'config/credentials.yml.enc', 'config/database.yml', 'config/master.key', 'config/secrets.yml'
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"

set :keep_releases, 5

before 'deploy:assets:precompile', 'deploy:yarn:build'
