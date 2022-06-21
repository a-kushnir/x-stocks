# frozen_string_literal: true

require 'active_record/migration'

namespace :db do
  namespace :migrate do
    desc 'Deletes schema_migrations records that refer to not existing migrations'
    task :cleanup => :environment do
      context = ActiveRecord::Base.connection.migration_context.open
      context.instance_variable_set(:@direction, :down) # Removes versions on record_version_state_after_migrating

      versions = context.migrated.to_a - context.migrations.map(&:version)
      $stdout.puts versions.any? ? "Deleted schema_migrations records:" : "No changes made"
      versions.each do |version|
        context.send(:record_version_state_after_migrating, version)
        $stdout.puts "  #{version}"
      end
    end
  end
end
