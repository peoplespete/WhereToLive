# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc "Pulls in 5900+ places"
task :load_places => :environment do
  raise 'You already have places' unless Place.count == 0
  file = File.open "us_cities.json"
  places = JSON.load file
  places.each do |place|
    Place.create(name: place['city'], state: place['state'])
    puts "#{place['city']}, #{place['state']}"
  end
end
