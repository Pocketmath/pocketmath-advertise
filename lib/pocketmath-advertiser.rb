require 'json'
require 'net/http'
require 'net/https'
require 'uri'

require 'rubygems'
require 'curb'

module PocketMath
  module PocketMath::Advertiser
    module PocketMath::Advertiser::V1
    
      API_BASE_URL = "https://api.pocketmath.com"
     
      def self.find_gps_list_id_by_name(name)
        p "get_gps_list_id"
        url = "#{API_BASE_URL}/v1/lists/gps/list.json?token=#{POCKETMATH_API_KEY}&limit=10000"
        response = Net::HTTP.get_response(URI.parse(url))
        data = response.body
        obj = JSON.parse(data)
        obj.each do |result|
          return result["id"] if result["name"] == name
        end
      end

      def self.create_gps_list(name)
        raise "name was nil" if name.nil?
        raise "name was blank" if name.empty? 
          
        add_list_json = JSON::generate(
           {
             "token" => "#{POCKETMATH_API_KEY}",
             "list" =>
                {
                   "name" => "#{name}"
                }
           })
     
        uri = URI.parse(API_BASE_URL)
        response = nil
        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Post.new("/v1/lists/gps/add_list.json")  
          request.body = add_list_json
          request.content_type = "application/json"
          response = http.request(request)
        end
        if !response.nil?
          data = response.body
          obj = JSON::parse(data)
          list_id = obj["id"]
          return list_id
        else
          return nil
        end
      end
      
      def self.upload_gps_list(id, coordinates = [])
        raise "id was nil" if id.nil?
        raise "coordinates was nil" if coordinates.nil?
        raise "coordiantes was empty" if coordinates.empty?
        
        c = Curl::Easy.new("#{API_BASE_URL}/v1/lists/gps/upload.json")
        c.multipart_form_post = true
        
        coordinates_string = ''
        coordinates.each do |coord|
          coordinates_string << "#{coord[:latitude]},#{coord[:longitude]}\r\n"
        end
        
        r = Random.new
        remote_file_name = "pm-advert-client-gps-list-#{r.rand(2*1000*1000*1000)}-#{r.rand(2*1000*1000*1000)}.txt"
        content_field = Curl::PostField.file('file', remote_file_name) do |field| 
          field.content = coordinates_string
        end
        
        success = nil
        
        success = c.http_post(
          content_field,
          Curl::PostField.content('token', POCKETMATH_API_KEY),
          Curl::PostField.content('mode', 'append'),
          Curl::PostField.content('list_id', id.to_s )
        )       

        return success
      end
      
      private
    
      def self.deep_copy(o)
        Marshal.load(Marshal.dump(o))
      end    
      
      public
      
      def self.create_insertion_order( opts =
        {
          "name" => nil,
          "start_datetime" => Date.now,
          "end_datetime" => Date.now + 7.days,
          "creative_type_ids" => [],
          "budget" => "1.00",
          "iab_catgories" => [],
          "bid_per_impression" => "2.00",
          "top_level_domain" => "pocketmath.com",
          "country" => "223",
          "image_url" => "https://s3.amazonaws.com/pocketmath/pocketmath_320x50.jpg",
          "landing_page_url" => "www.pocketmath.com",
          "size_id" => "11"
        })
        
        o = deep_copy(opts)
        
        if o["name"].nil?
          raise "name was nil"
        end
        
        if o["iab_category_codes"].empty?
          raise "no iab_category_codes specified"
        end
        
        if o["start_datetime"].is_a?(Date)
          o["start_datetime"] = o["start_datetime"].strftime("%d %b %Y")
        elsif ! o["start_datetime"].is_a?(String)
          raise "unsupported type"
        end
        
        if o["end_datetime"].is_a?(Date)
          o["end_datetime"] = o["end_datetime"].strftime("%d %b %Y")
        elsif ! o["end_datetime"].is_a?(String)
          raise "unsupported type"
        end
        
        obj = { "token" => POCKETMATH_API_KEY, "io" => o }
        
        create_io_json = JSON.generate(obj)
        
        uri = URI.parse(API_BASE_URL)
        response = nil
        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Post.new("/v1/io/create.json")  
          request.body = create_io_json
          request.content_type = "application/json"
          response = http.request(request)
        end
        if !response.nil?
          data = response.body
          p response
          p data
          obj = JSON::parse(data)
          io_id = obj["id"]
          return io_id
        else
          return nil
        end
        
      end
      
    end # module PocketMath::Advertiser::V1
  end # module PocketMath::Advertiser
end # module PocketMath