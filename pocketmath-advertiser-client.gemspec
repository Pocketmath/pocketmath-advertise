Gem::Specification.new do |s|
  s.name        = 'pocketmath-advertiser-client'
  s.version     = '0.0.1'
  s.date        = '2014-01-05'
  s.summary     = "PocketMath Advertiser Client"
  s.description = "A client to connect to the PocketMath advertising API."
  s.authors     = ["Eric Tucker"]
  s.email       = 'eric@pocketmath.com'
  s.files       = ["lib/pocketmath-advertiser-client.rb"]
  s.homepage    = 'http://github.com/pocketmath/pocketmath-advertiser-client'
  s.license     = 'Apache2'
  s.add_runtime_dependency 'curb'
end