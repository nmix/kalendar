Gem::Specification.new do |s|
  s.name        = 'kalendar'
  s.version     = '0.1.0'
  s.date        = '2018-08-23'
  s.summary     = "A simple calendar gem"
  s.description = "A simple calendar gem"
  s.authors     = ["Nikolay Mikhaylichenko"]
  s.email       = 'nn.mikh@yandex.ru'
  s.homepage    =
    'https://github.com/nmix/kalendar'
  s.license       = 'MIT'

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "README.md"]

  s.add_development_dependency 'rspec', '~> 3.7'
end

