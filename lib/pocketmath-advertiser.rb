require 'json'
require 'net/http'
require 'net/https'
require 'uri'

require 'rubygems'
require 'curb'

module PocketMath
  module PocketMath::Advertiser
    module PocketMath::Advertiser::V1
      
      DEFAULT_API_BASE_URL = "https://api.pocketmath.com"
      
      def self.open(pocketmath_api_key, pocketmath_api_base_url = DEFAULT_API_BASE_URL)
        return Client.new(pocketmath_api_key, pocketmath_api_base_url)
      end
      
      class PocketMath::Advertiser::V1::Client
        
        def initialize(pocketmath_api_key, pocketmath_api_base_url)
          @pocketmath_api_key = pocketmath_api_key
          @pocketmath_api_base_url = pocketmath_api_base_url
        end
        
        def close
        end
     
        def find_gps_list_id_by_name(name)
          p "get_gps_list_id"
          url = "#{@pocketmath_api_base_url}/v1/lists/gps/list.json?token=#{@pocketmath_api_key}&limit=10000"
          response = Net::HTTP.get_response(URI.parse(url))
          data = response.body
          obj = JSON.parse(data)
          obj.each do |result|
            return result["id"] if result["name"] == name
          end
        end

        def create_gps_list(name)
          raise "name was nil" if name.nil?
          raise "name was blank" if name.empty? 
          
          add_list_json = JSON::generate(
             {
               "token" => "#{@pocketmath_api_key}",
               "list" =>
                  {
                     "name" => "#{name}"
                  }
             })
     
          uri = URI.parse(@pocketmath_api_base_url)
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
      
        def upload_gps_list(id, coordinates = [])
          raise "id was nil" if id.nil?
          raise "coordinates was nil" if coordinates.nil?
          raise "coordiantes was empty" if coordinates.empty?
        
          c = Curl::Easy.new("#{@pocketmath_api_base_url}/v1/lists/gps/upload.json")
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
            Curl::PostField.content('token', @pocketmath_api_key),
            Curl::PostField.content('mode', 'append'),
            Curl::PostField.content('list_id', id.to_s )
          )       

          return success
        end
        
        def get_insertion_order_stats(id, start_date = nil, end_date = nil)
          url = "#{@pocketmath_api_base_url}/v1/stats/id.json?token=#{@pocketmath_api_key}&id=#{URI.encode(id)}"
          start_date_string = to_date_string(start_date)
          end_date_string = to_date_string(end_date)
          url << "&start_date=#{URI.encode(start_date_string)}" if !start_date_string.nil?
          url << "&end_date=#{URI.encode(end_date_string)}" if !end_date_string.nil?
          uri = URI.parse(url)
          
          response = Net::HTTP.get(uri)
          p response

          if !response.nil?
            data = response
            obj = JSON::parse(data)
            stats = obj["stats"]
            return nil if stats.nil?
            io_totals = stats["io_totals"]
            return nil if io_totals.nil?
            iostats = InsertionOrderStats.create({
              :impressions => io_totals["imp"].to_i,
              :clicks => io_totals["clk"].to_i,
              :conversions => io_totals["conv"].to_i,
              :spend => io_totals["spend"].to_f,
              :cpm => io_totals["cpm"].to_f,
              :cpc => io_totals["cpc"].to_f,
              :cpa => io_totals["cpa"].to_f,
              :ctr => io_totals["ctr"].to_f
            })
            return iostats
          else
            return nil
          end          
        end
        
        private
    
        def deep_copy(o)
          Marshal.load(Marshal.dump(o))
        end
        
        def to_date_string(o)
          if o.nil?
            return nil
          elsif o.is_a?(Date)
            return o.strftime("%d %b %Y")
          elsif o.is_a?(String)
            raise "case not handled"
          end
        end
      
        public
      
        def create_insertion_order( opts =
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
        
          obj = { "token" => @pocketmath_api_key, "io" => o }
        
          create_io_json = JSON.generate(obj)
        
          uri = URI.parse(@pocketmath_api_base_url)
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
      
      end # end Client
      
    end # module PocketMath::Advertiser::V1
  end # module PocketMath::Advertiser
end # module PocketMath