require 'csv'
require 'open-uri'
require 'pry'
require 'twilio-ruby'

twilio = Twilio::REST::Client.new(ENV["TWILIO_SID"], ENV["TWILIO_AUTH"])

# def url_to_csv(url)
#   download = open(url)
#   CSV.new(download)
# end

RAD_PER_DEG = Math::PI / 180
RM = 6371000 # Earth radius in meters

def distance_between(lat1, lon1, lat2, lon2)
  lat1_rad, lat2_rad = lat1 * RAD_PER_DEG, lat2 * RAD_PER_DEG
  lon1_rad, lon2_rad = lon1 * RAD_PER_DEG, lon2 * RAD_PER_DEG

  a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

  RM * c # Delta in meters
end

fire_data_url = 'https://firms.modaps.eosdis.nasa.gov/active_fire/c6/text/MODIS_C6_USA_contiguous_and_Hawaii_24h.csv'

users_data_url = 'https://still-wave-89139.herokuapp.com/users.csv'

fire_download = open(fire_data_url)
fire_csv = CSV.parse(fire_download, :headers=>true)

user_download = open(users_data_url)
user_csv = CSV.parse(user_download, :headers =>true)

user_csv.each do |u_row|
  p u_row
  notified = false
  fire_csv.each do |f_row|
    user_ll = [u_row['latitude'].to_f, u_row['longitude'].to_f]
    fire_ll = [f_row['latitude'].to_f, f_row['longitude'].to_f]
    distance = distance_between(user_ll[0], user_ll[1], fire_ll[0], fire_ll[1])
    if distance < 48280 
      p 'Fire Detected ' + distance.to_s + ' meters away! - ' +  f_row['latitude'] + 'Long: ' + f_row['longitude']
      notified = true
      twilio.messages.create to: '2096275373', from: '2096501747', body: 'Fire detected within 30mi, run dude!'
    end
    break if notified
  end
  next if notified
end

