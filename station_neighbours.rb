require './station_distance.rb'

def neighbour_interface
  p 'Downloading list of stations, please wait...'
  station_list = fetch_stations('https://raw.githubusercontent.com/trainline-eu/stations/master/stations.csv')
  country_display(station_list)
  p 'Quel est le pays dont les gares vous intéressent ?'
  country = gets.chomp.downcase
  station_array = station_country(country, station_list)
  p 'entrez le 2 premières lettres de la gare recherchée'
  short_list = prefix_choice(station_array)
  station = central_station_selector(short_list)
  p "quelle rayon maxi pour les gares aux alentours de #{station[0][:name]} ?"
  radius = gets.chomp.to_i
  station_array = stations_neighbour_selector(station_array, station, radius)
  p "Gares dans un rayon de #{radius} km autour de #{station[0][:name]} :"
  station_array.each { |st| p st[:name] }
end

def station_country(country, station_list)
  station_array = []
  station_list.each_with_index do |row, index|
    if row[8].downcase == country
      station_array << { id: index + 1, name: row[1], latitude: row[5], longitude: row[6], country: row[8], is_main_st: row[11] }
    end
  end
  station_array
end

def distance_calc(coord)
  lx = Math.cos(coord[1]) * (coord[2] - coord[0]) * 6371
  ly = (coord[3] - coord[1]) * 6371
  Math.sqrt(lx**2 + ly**2)
end

def country_display(station_list)
  country_list = []
  station_list.each { |st| country_list << st[8].downcase }
  country_list.uniq.each { |country| p country }
end

def prefix_choice(station_array)
  prefix = gets.chomp.downcase
  short_list = station_array.select do |st|
    st[:name][0, 2].downcase == prefix
  end
  short_list.each_with_index do |st, index|
    st[:id] = index
    p "#{st[:id]} - #{st[:name]}"
  end
  short_list
end

def central_station_selector(short_list)
  # attention, il faut que les :id correspondent aux indices de tableau
  p "Donnez l'indice de la gare souhaitée"
  station = []
  station_id = gets.chomp.to_i
  station << short_list[station_id]
end

def stations_neighbour_selector(station_array, station, radius)
  station_array.keep_if do |st|
    distance_calc(coordinates_buider([station[0], st])) < radius \
    && !st[:latitude].nil? # && st[:is_main_st] == 't'
  end
  station_array
end

# neighbour_interface
