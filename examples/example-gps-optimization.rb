require 'pocketmath-advertise'

require 'yaml'

CREDENTIALS_PATH = ARGV[0]

# Load credentials
CREDENTIALS = YAML::load( File.open(CREDENTIALS_PATH) ) 

# Available at https://console.pocketmath.com/api
POCKETMATH_API_KEY = CREDENTIALS['pocketmath_api_key']

# Available at http://developer.mapquest.com/web/products/open
MAPQUEST_API_KEY = CREDENTIALS['mapquest_api_key']

def create_gps_io(name, locations = [])
  
  api_client = PocketMath::Advertiser::V1.open(POCKETMATH_API_KEY)
  geocode_client = PocketMath::Geocode.open( { :mapquest_api_key => MAPQUEST_API_KEY } )
  
  # lookup GPS coordinates
  gps = []
  locations.each do |location|
    gps = gps + geocode_client.get_gps_coordinates(location)
  end
  gps = gps.zip.flatten.compact # smooth all arrays into one
  
  # create and populate GPS list
  gps_list_name = "#{name} GPS list"
  gps_list_id = api_client.create_gps_list(gps_list_name)
  upload_success = api_client.upload_gps_list(gps_list_id, gps)
  
  raise "failed to upload GPS list" if !upload_success
  
  now = Date.today
  
  # create the insertion order hash
  # * = Values you'll need from here:  https://pocketmath.tenderapp.com/kb/api/api-variable-reference
  insertion_order =
    {
      "name" => name,
      
      # OUR GPS LIST!
      "whitelist_ids" => [ gps_list_id ],
      
      # all times UTC
      "start_datetime" => now,
      "end_datetime" => now + 2,     # + 2 days
      
      # Max CPM per impression (USD)
      "bid_per_impression" => "1.00",
      
      # Total budget (USD)
      "budget" => "1.00",      
      
      # Must specify exactly one country
      "country" => "223", # United States  *See reference.
      # Creative details
      "top_level_domain" => "pocketmath.com",
      "image_url" => "https://s3.amazonaws.com/pocketmath/pocketmath_320x50.jpg", # Banner image
      "landing_page_url" => "http://www.pocketmath.com",
      "size_id" => "2", # 320x50 standard banner  *See reference.
    
      # Creative type
      "creative_type_ids" => [], # Nothing unusual, leave empty array.  *See reference.
      
      # Ad category
      "iab_category_codes" => ["IAB3-1"], # Advertising -- b/c we're an advertising company!  *See reference.
    }
    
    p insertion_order
    
  # hit the API with our new order!
  io_id = api_client.create_insertion_order( insertion_order )
  
  geocode_client.close
  
  api_client.close
  
  return io_id
  
end

INSERTION_ORDER_NAME = ARGV[1]

io_id = create_gps_io "#{INSERTION_ORDER_NAME}", [ "Pyongyang, North Korea" ]
p "Check out your new IO: https://console.pocketmath.com/io/#{io_id}"

#client = PocketMath::Advertiser::V1.open(POCKETMATH_API_KEY)
#insertion_order_stats = client.get_insertion_order_stats("AAABQ34MJssABO-kX3eJGSCWpsQz6wrvspe-zA")
#p JSON.generate(insertion_order_stats)