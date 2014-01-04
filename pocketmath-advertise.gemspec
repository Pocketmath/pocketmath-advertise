Gem::Specification.new do |s|
  s.name        = 'pocketmath-advertise'
  s.version     = '0.0.1-2'
  s.date        = '2014-01-05'
  s.summary     = "PocketMath Advertiser Client"
  s.description = "A client to connect to the PocketMath advertising API."
  s.authors     = ["Eric Tucker"]
  s.email       = 'eric@pocketmath.com'
  s.files       = [
    'lib/pocketmath-advertise.rb',
    'lib/pocketmath-advertiser.rb',
    'lib/pocketmath-geocode.rb'
    ]
  s.homepage    = 'http://github.com/pocketmath/pocketmath-advertise'
  s.license     = 'Apache2'
  s.add_runtime_dependency 'curb', '~> 0'
end
