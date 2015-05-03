Gem::Specification.new do |gem|
  gem.name        = 'resilient_queue'
  gem.version     = '0.1.0'
  gem.licenses    = 'MIT'
  gem.authors     = ['Justin Scott']
  gem.email       = 'jvscott@gmail.com'
  gem.homepage    = 'http://www.github.com/jscott/resilient_queue/'
  gem.summary     = 'Resilient Queue'
  gem.description = 'Queueing in a competent, reliable way with pure Ruby'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- test/**/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  # gem.required_ruby_version = '>= 2.1'

  # gem.add_runtime_dependency 'exponential-backoff'
  gem.add_runtime_dependency 'moneta'
  gem.add_runtime_dependency 'daybreak'
  gem.add_runtime_dependency 'redislike'
  # gem.add_runtime_dependency 'ezmq'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'kintama'
  gem.add_development_dependency 'simplecov'
end
