require './station_distance.rb'
require './station_neighbours.rb'

def station_trip
  p 'Downloading list of stations, please wait...'
  station_list = fetch_stations('https://raw.githubusercontent.com/trainline-eu/stations/master/stations.csv')
  station_array = station_select(station_list)
  station_array.each_with_index do |st, index|
    p "#{st[:id]} - #{st[:name]}"
    break if index > 50
  end
  station = station_user_selector(station_array)
  trip = []
  trip << station[0]
  coord = coordinates_buider(station)
  while distance_calc(coord) > 100
    station_array = station_select(station_list)
    step = [{ id: 999_999,
              name: 'noname',
              latitude: to_deg((coord[3] - coord[1]) * 60 / distance_calc(coord) + coord[1]),
              longitude: to_deg((coord[2] - coord[0]) * 60 / distance_calc(coord) + coord[0]),
              country: 'nocountry',
              is_main_st: false }]
    station_around = stations_neighbour_selector(station_array, step, 70)
    station_around.each do |st|
      if distance_calc(coordinates_buider([st, station[1]])) \
        < distance_calc(coordinates_buider(station))
        station[0] = st
      end
    end
    trip << station[0]
    coord = coordinates_buider(station)
  end
  p "un trajet possible pour rejoindre #{station[1]\
  [:name]} depuis #{trip[0][:name]} passerait par :"
  trip.drop(1).each { |st| p st[:name] }
end

def to_deg(angle)
  angle.to_f / 0.017453292519943295
end

station_trip
