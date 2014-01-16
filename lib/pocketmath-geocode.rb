require 'json'
require 'net/http'
require 'uri'

module PocketMath
  module PocketMath::Geocode

    DEFAULT_GEOCODING_PROVIDER = :open # May also use :google (see Google Map API Terms of Service to determine licensing requirements)

    def self.open( opts = { :mapquest_api_key => nil, :provider => DEFAULT_GEOCODING_PROVIDER } )
      return Geocode::Client.new(opts)
    end
    
    class PocketMath::Geocode::Client
    
      private
    
      def initialize( opts = { :mapquest_api_key => nil, :provider => DEFAULT_GEOCODING_PROVIDER } )
        if !opts[:provider].nil?
          @provider = opts[:provider]
        else 
          @provider = DEFAULT_GEOCODING_PROVIDER
        end

        if !opts[:mapquest_api_key].nil?
          @mapquest_api_key = opts[:mapquest_api_key]
        else
          @mapquest_api_key = nil
        end

        if @provider == :open && @mapquest_api_key.nil?
          raise "Geocoding provider OPEN requires MapQuest API key.  No key was specified.  Please specify like this:  Geocode.open{ :mapquest_api_key => \"...\" }"
        end
      end

      private 

      def get_gps_coordinates_open(location, max_results = 1)
        url = "http://open.mapquestapi.com/geocoding/v1/address?key=#{@mapquest_api_key}&location=#{URI.encode(location)}&maxResults=#{max_results.to_s}&inFormat=kvp&outFormat=json&json=true"
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
      def get_gps_coordinates_google(location, max_results = 1)
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

      def get_gps_coordinates(location, max_results = 1)
        if @provider == :google
          return get_gps_coordinates_google(location, max_results)
        elsif @provider == :open
          return get_gps_coordinates_open(location, max_results)
        else
          raise "map provider was not specified"
        end
      end
    
      def close
      end

    end
  end
end