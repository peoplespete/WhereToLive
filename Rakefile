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

desc "Pulls in geocoded information"
task :add_geocoded_info => :environment do
  Place.all.each do |place|
    next if place.latitude && place.longitude && place.county && place.postcode
    begin
      result = Geocoder.search("#{place.name}, #{place.state}").first.data
      latitude = result['lat'].to_f
      longitude = result['lon'].to_f
      county = result['address']['county']
      postcode = result['address']['postcode']
      place.update(latitude: latitude, longitude: longitude, county: county, postcode: postcode)
      puts "#{place.name}, #{place.state}: #{latitude}, #{longitude}, #{county}, #{postcode}"
    rescue
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
  end
end

desc "Pulls in climate data"
task :add_climate => :environment do
  Place::CAPITALS.each do |state, capital|
    next unless state.to_s.in?(Place::STATES)
    puts "#{capital}, #{state}"
    # Launchy.open("https://www.timeanddate.com/weather/usa/#{capital}/climate".downcase)
    data = File.read("climate_data/#{capital.downcase}.txt").split("\n")
    temperatures = []
    precipitations = []
    data.each_with_index do |line, i|
      if i % 3 == 1
        temperatures.push(line[0..1].to_i)
        temperatures.push(line[2..3].to_i)
      elsif i % 3 == 2
        precipitations.push(line.to_f)
      end
    end

    precipitation = precipitations.inject{ |sum, el| sum + el }.to_f / precipitations.size
    Place.where(state: state.to_s).update_all(precipitation: precipitation, temperature_min: temperatures.min, temperature_max: temperatures.max)
  end
end


desc "Pulls in distance to places"
task :add_distance_to => :environment do
  gmaps = GoogleMapsService::Client.new(key: Rails.application.credentials.google_maps_key)

  Place.all.each do |place|
    ['Winston-Salem, NC, USA', 'Philadelphia, PA, USA'].each do |destination|
      destination_column = destination[/winston/i] ? 'hours_to_winston' : 'hours_to_philly'
      next if place.send(destination_column).present?
      begin
        routes = gmaps.directions(
          "#{place.name}, #{place.state}, USA",
          destination,
          mode: 'driving',
          alternatives: false)
        hours_to = routes.first[:legs].first[:duration][:value]/(60*60).to_f
        place.update(destination_column => hours_to)
        puts "#{place.name}, #{place.state}: #{hours_to.round(2)} to #{destination[/.+,/][0..-2]}"
      rescue
      end
    end
  end
end


desc "Pulls in population"
task :add_population => :environment do
  agent = Mechanize.new
  Place.all.each do |place|
    next if place.population.present? && place.population_density.present?

    begin
      county = place.county
      county+= ' County' unless county[/county/i]
      county.gsub!(' ','-')
      url = "https://population.us/county/#{place.state_code.downcase}/#{county.downcase}/"
      page = agent.get(url)
      # Launchy.open(url)
      population = page.search(".divwidth b").first.children.first.text.gsub(',','').to_i
      population_density = page.search(".divwidth b")[2].children.first.text.gsub(',','')[/.+p\/mi/][/\d+.\d+/].to_i

      population = nil if population == 0
      population_density = nil if population_density == 0

      place.update(population: population, population_density: population_density)
      puts "#{place.name}, #{place.state_code}, #{place.county}: #{population}, #{population_density}"
    rescue
      puts "Error with #{place.name}, #{place.state_code}, #{place.county}"
    end
  end
end


