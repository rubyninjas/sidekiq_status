unless $LOAD_PATH.include?(lib = File.expand_path('../lib', __FILE__))
  $LOAD_PATH.unshift(lib)
end

Gem::Specification.new do |spec|
  spec.name          = 'mst-status-sidekiq'
  spec.version       = '0.0.4'

  spec.authors       = ['John Doe']
  spec.email         = ['mail@exampple.com']
  spec.summary       = %q(Status plugin for sidekiq monitoring)
  spec.description   = spec.summary
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files | grep modules | grep sidekiq`.split($/)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mst-status' 
  spec.add_runtime_dependency 'redis'
  spec.add_runtime_dependency 'redis-namespace'
  spec.add_runtime_dependency 'sidekiq'
end
