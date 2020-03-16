# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc "Pulls in 5900+ places"
task :load_places => :environment do
  raise 'You already have places' unless Place.count == 0
  agent = Mechanize.new

  Place::STATES.each do |state|
    puts state.capitalize
    url = "https://en.wikipedia.org/wiki/List_of_cities_in_#{state.gsub(' ','_')}"
    page = agent.get(url)
    # Launchy.open(url)
    state_index = state == 'Virginia' ? 1 : 0
    table = page.search("table.wikitable")[state_index]
    headers = table.search('th').map{|header| header.text.strip }
    name_index = headers.index(headers.find{|header| header[/name|city/i]}) + 1
    county_index = headers.index(headers.find{|header| header[/county|origin/i]}) + 1
    population_index = headers.index(headers.find{|header| header[/population|estimate/i]}) + 1
    table.search('tr').each_with_index do |row, i|
      next if i == 0
      next if i == 1 if state == 'South Carolina'
      begin
        name = if state == 'Virginia'
          row.search("td,th:nth-child(#{name_index})").children.first.attributes['title'].text.split(',').first
        else
          row.search("td:nth-child(#{name_index})").children.first.attributes['title'].text.split(',').first
        end
        population = row.search("td:nth-child(#{population_index})").children.first.text.gsub(',','').to_i
        county = row.search("td:nth-child(#{county_index})").text.split('/').first.strip
        if(state == 'Virginia')
          county_words = county.split(' ')
          county = county_words[county_words.index('County') - 1]
        end

        puts "#{name}, #{state}, #{county}, #{population}"
        Place.create(name: name, state: state, county: county, population: population)
      rescue
        puts "error with #{name}"
      end
    end
    puts '==============================='
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
      place.update(latitude: latitude, longitude: longitude)
      puts "#{place.name}, #{place.state}: #{latitude}, #{longitude}"
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

desc "Pulls in real estate data"
task :add_home_pricing => :environment do
  data = CSV.read("zillow_data/sales_by_county.csv")
  heading_row = data.shift
  csv_places = []
  data.each do |row|
    county = row[1]
    state = row[2]
    home_price = row[-6..-1].map(&:to_i).inject{ |sum, el| sum + el }.to_i / 6
    hsh = {
      county: county,
      state: state,
      home_price: home_price,
    }
    csv_places.push(hsh)
  end

  problem_places = Place.all.select do |place|
    !csv_places.any?{|csv_place| csv_place[:county] == place.county && csv_place[:state] == place.state}
  end

  problem_places.each do |place|
    next unless place.county.present?
    unless place.county[/county/i]
      place.update(county: "#{place.county} County")
    end
  end


  Place.all.each do |place|
    csv_place = csv_places.detect{ |csv_place| csv_place[:county] == place.county && csv_place[:state] == place.state }
    next unless csv_place
    puts "Adds #{place.name}, #{place.state}: #{csv_place[:home_price]}"
    place.update(home_price: csv_place[:home_price])
  end
end


desc "Pulls in school data"
task :add_schools => :environment do
  GreatSchools::API.key = Rails.application.credentials.great_schools_key
  Place.all.each do |place|
    next if place.school_rating.present?

    begin
      schools = GreatSchools::School.browse(place.state_code, place.name, { school_types: ['public', 'charter'] })
      ratings = schools.map(&:rating).map(&:to_i).compact
      school_rating = ratings.inject{ |sum, el| sum + el }.to_f / ratings.size

      puts "Adds #{place.name}, #{place.state}: #{school_rating}"
      place.update(school_rating: school_rating)
    rescue
    end
  end
end



