# frozen_string_literal: true

# bundle exec cap production deploy

server 'xstocks.tk', user: 'deploy', roles: %w[app db web], my_property: :my_value

set :ssh_options, {
  forward_agent: false,
  auth_methods: %w[password]
}
