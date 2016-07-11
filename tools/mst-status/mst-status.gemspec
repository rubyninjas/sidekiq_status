unless $LOAD_PATH.include?(lib = File.expand_path('../lib', __FILE__))
  $LOAD_PATH.unshift(lib)
end

Gem::Specification.new do |spec|
  spec.name          = 'mst-status'
  spec.version       = '0.0.5'

  spec.authors       = ['John Doe']
  spec.email         = ['mail@example.com']
  spec.summary       = %q(Rack middleware in the service of displaying apps keepalive status)
  spec.description   = spec.summary
  spec.homepage      = ''
  spec.license       = 'MIT'

  plugin_files = Dir['mst-status-*.gemspec'].map { |gemspec|
     eval(File.read(gemspec)).files
  }.flatten.uniq

  spec.files         = `git ls-files`.split($/) - plugin_files
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rack'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'oj'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-mocks'
end
