require 'csv'
require 'open-uri'

def fetch_stations(url)
  url = 'stations.csv' if File.file?('stations.csv')
  csv_text = open(url)
  CSV.parse(csv_text, headers: true, col_sep: ';')
end

def to_rad(angle)
  angle.to_f * 0.017453292519943295
end

def distance_calc(coord)
  a1 = Math.sin(coord[3] - coord[1])
  a2 = Math.cos(coord[3]) * Math.cos(coord[1])
  a3 = Math.sin(coord[2] - coord[0])
  a = a1**2 + a2 * a3**2
  b = Math.sqrt(a) / Math.sqrt(1 - a)
  c = Math.atan(b)
  (6371 * c).to_i
end

def station_user_selector(station_array)
  station = []
  p 'please select departure station id'
  station << station_array[gets.chomp.to_i]
  p 'please select arrival station id'
  station << station_array[gets.chomp.to_i]
end

def station_select(station_list)
  station_array = []
  station_list.each_with_index do |row, index|
    station_array << { id: index,
                       name: row[1],
                       latitude: row[5],
                       longitude: row[6],
                       country: row[8],
                       is_main_st: row[11] }
  end
  station_array
end

def coordinates_buider(station)
  long1 = to_rad(station[0][:longitude].to_f)
  lat1 = to_rad(station[0][:latitude].to_f)
  long2 = to_rad(station[1][:longitude].to_f)
  lat2 = to_rad(station[1][:latitude].to_f)
  [long1, lat1, long2, lat2]
end

def distance_interface
  p 'Downloading list of stations, please wait...'
  station_list = fetch_stations('https://raw.githubusercontent.com/trainline-eu/stations/master/stations.csv')
  station_array = station_select(station_list)
  station_array.each_with_index do |st, index|
    p "#{st[:id]} - #{st[:name]}"
    break if index > 50
  end
  station = station_user_selector(station_array)
  coordinates = coordinates_buider(station)
  p '---------------------------------------------'
  p "#{station[0][:name]} and #{station[1][:name]}\
 are separated by #{distance_calc(coordinates)} km"
  p '---------------------------------------------'
end
# station_list = fetch_stations('https://raw.githubusercontent.com/trainline-eu/stations/master/stations.csv')
# p station_select(station_list)
# distance_interface
