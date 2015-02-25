require 'twitter'
require 'json'
require_relative 'config.rb'

client = Twitter::REST::Client.new do |config|
  config.consumer_key = TWITTER_CONSUMER_KEY
  config.consumer_secret = TWITTER_CONSUMER_SECRET
  config.access_token = TWITTER_ACCESS_TOKEN
  config.access_token_secret = TWITTER_ACCESS_SECRET
end

weather_data = `curl #{WEATHER_URL}`
raise 'weather download error' if weather_data.lines.length < 4
weather_data = weather_data.lines.map {|line| line.split('#')}
region_data = weather_data.select {|region| region[1] == WEATHER_REGION}[0]
raise 'weather region error' if region_data.nil?

if File.exists? 'tomorrow.json'
  json = JSON.parse File.read('tomorrow.json')
  client.update "#{json['conditions']} with a high of #{json['high']} degrees."
end

File.open 'tomorrow.json', 'w' do |file|
  file.write JSON.generate('conditions': region_data[23].chomp('.').chomp, 'high': region_data[9])
end
