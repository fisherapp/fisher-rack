# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fisher/rack/version'

Gem::Specification.new do |spec|
  spec.name          = "fisher-rack"
  spec.version       = Fisher::Rack::VERSION
  spec.authors       = ["Trae Robrock"]
  spec.email         = ["trobrock@fisherapp.com"]
  spec.description   = %q{Simple piece of rack middleware to track stats}
  spec.summary       = %q{Simple piece of rack middleware to track stats}
  spec.homepage      = "https://github.com/fisherapp/fisher-rack"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency "ruby-statsd", "~> 1.2.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
