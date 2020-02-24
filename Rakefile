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

desc "Pulls in latitude and longitude"
task :add_latitude_and_longitude => :environment do
  Place.all.each do |place|
    next if place.latitude && place.longitude
    begin
      result = Geocoder.search("#{place.name}, #{place.state}").first.data
      latitude = result['lat'].to_f
      longitude = result['lon'].to_f

      place.update(latitude: latitude, longitude: longitude)
      puts "#{place.name}, #{place.state}: #{latitude}, #{longitude}"
      # sleep 5
    rescue
      # sleep 30
    end
  end
end

desc "Pulls in walkability"
task :add_walkability => :environment do
  # walk_score_key = '53fe57a473d7d92b1fc3df8e626f4b40'
  walk_score_key = '0a373caf865239d8ca1013929bbe32f0'

  url = 'http://api.walkscore.com/score'

  Place.all.each do |place|
    next unless place.latitude.present? && place.longitude.present? && place.walk_score.blank?
    begin
      query = {
        format: 'JSON',
        wsapikey: walk_score_key,
        address: "#{place.name}, #{place.state}",
        lat: place.latitude,
        lon: place.longitude,
      }
      response = HTTParty.get(url, query: query)
      walk_score = response.body[/score: \d+/][7..8].to_i rescue nil
      place.update(walk_score: walk_score)
      puts "#{place.name}, #{place.state}: #{walk_score}"
    rescue
    end
    # binding.pry
  end
end
