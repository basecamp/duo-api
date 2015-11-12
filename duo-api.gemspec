# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'duo-api/version'

Gem::Specification.new do |spec|
  spec.name          = "duo-api"
  spec.version       = DuoApi::VERSION
  spec.authors       = ["Jon Phenow"]
  spec.email         = ["j.phenow@gmail.com"]

  spec.summary       = %q{Duo API helps you interact with the Duo 2-factor authentication service}
  spec.description   = %q{Simplify your API communications with Duo. Sign out-going requests, receive consistent responses, Sign web requests, and verify their responses }
  spec.homepage      = "https://github.com/highrisehq/duo-api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
