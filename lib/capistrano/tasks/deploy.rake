# frozen_string_literal: true

namespace :deploy do
  namespace :yarn do
    desc 'Builds assets using `yarn build`'
    task :build do
      on release_roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env), rails_groups: fetch(:rails_assets_groups) do
            execute :yarn, :install
            execute :yarn, :build
          end
        end
      end
    end
  end
end
