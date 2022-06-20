# frozen_string_literal: true

namespace :support do
  namespace :users do
    desc 'Deletes the user'
    task :delete, [:email] => :environment do |_task, args|
      email = args[:email]
      user = XStocks::AR::User.find_by!(email: email)
      $stdout.puts "Do you want to delete #{email} user? [y/n]"
      user.destroy if $stdin.gets.strip == 'y'
      $stdout.puts 'Complete'
    end
  end
end
