require 'json'
require 'open-uri'
require 'net/http'
require 'uri'

module PocketMath
  module PocketMath::Geocode

    GEOCODING_PROVIDER = :open # May also use :google (see Google Map API Terms of Service to determine licensing requirements)

    private 

    def self.get_gps_coordinates_open(location, max_results = 1)
      url = "http://open.mapquestapi.com/geocoding/v1/address?key=#{MAPQUEST_API_KEY}&location=#{URI.encode(location)}&maxResults=#{max_results.to_s}&inFormat=kvp&outFormat=json&json=true"
      response = Net::HTTP.get_response(URI.parse(url))
      data = response.body
      obj = JSON.parse(data)
      p url
      p obj
      gps_coordinates = []
      obj["results"].each do |result|
        result["locations"].each do |location|
          lat_lng = location["latLng"]
          gps_coordinates << { :latitude => lat_lng["lat"], :longitude => lat_lng["lng"] }
        end
      end
      return nil if gps_coordinates.empty?
      return gps_coordinates
    end

    private 

    #
    # Use of the Google Map API requires licensing from Google.
    #
    def self.get_gps_coordinates_google(location, max_results = 1)
      url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(location)}&sensor=true"
      response = Net::HTTP.get_response(URI.parse(url))
      data = response.body
      obj = JSON.parse(data)
      p url
      p obj
      gps_coordinates = []
      n = 0
      obj["results"].each do |result|
        break if n >= max_results
        geometry = result["geometry"]
        raise "geometry was unavailable" if geometry.nil?
        location = geometry["location"]
        raise "location was unavailable" if location.nil?
        lat = location["lat"]
        lng = location["lng"]
        gps_coordinates << { :latitude => lat, :longitude => lng }
        n += 1
      end
      return nil if gps_coordinates.empty?
      return gps_coordinates  
    end

    public

    def self.get_gps_coordinates(location, max_results = 1)
      if GEOCODING_PROVIDER == :google
        return get_gps_coordinates_google(location, max_results)
      elsif GEOCODING_PROVIDER == :open
        return get_gps_coordinates_open(location, max_results)
      else
        raise "map provider was not specified"
      end
    end

  end
end