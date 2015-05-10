Gem::Specification.new do |gem|
  gem.name        = 'stubborn_queue'
  gem.version     = '1.1.0'
  gem.licenses    = 'MIT'
  gem.authors     = ['Justin Scott']
  gem.email       = 'jvscott@gmail.com'
  gem.homepage    = 'http://www.github.com/jscott/stubborn_queue/'
  gem.summary     = 'Stubborn Queue'
  gem.description = 'Queueing that keeps on kicking until you tell it to stop.'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- test/**/*`.split("\n")
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.1'

  gem.add_runtime_dependency 'bundler'
  gem.add_runtime_dependency 'moneta'
  gem.add_runtime_dependency 'daybreak'
  gem.add_runtime_dependency 'redislike'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'kintama'
  gem.add_development_dependency 'simplecov'
end
