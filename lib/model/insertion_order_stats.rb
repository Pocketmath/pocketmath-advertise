module PocketMath::Advertiser::V1
  
  class InsertionOrderStats
    
    # Cost per thousand Impressions
    attr_reader :cpm
    
    # Cost per Click
    attr_reader :cpc
    
    # Cost per Action (Cost per Conversion)
    attr_reader :cpa
    
    # Click-through Rate (Clicks per impression)
    attr_reader :ctr
    
    attr_reader :impressions, :clicks, :conversions
    
    # Ad spend in currency
    attr_reader :spend
    
    private
    
    attr_writer :cpm, :cpc, :cpa, :ctr
    attr_writer :impressions, :clicks, :conversions
    attr_writer :spend    
    
    public
    
    # Create a new instance.
    # * Specify attributes in a hash as { :cpm => 1.25, :cpc => 2.33, ... }
    def self.create(opts = {})
      iostats = InsertionOrderStats.new
      opts.each_pair do |k,v|
        raise "#{k.to_s}=#{v} was not a number" if !v.is_a?(Numeric)
        iostats.send(k.to_s + "=", v)
      end
    end
    
  end
  
end