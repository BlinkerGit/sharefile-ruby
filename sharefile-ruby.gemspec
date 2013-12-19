# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sharefile-ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "sharefile-ruby"
  spec.version       = SharefileRuby::VERSION
  spec.authors       = ["Anton Avguchenko", "Val Brodsky", "Brad Bennett"]
  spec.email         = ["avguchenko+made-this-up@github.com", "vlb@zestfinance.com", "bjb@zestfinance.com"]
  spec.summary       = %q{Ruby wrapper for the sharefile api}
  spec.description   = %q{Create friendly ruby apis for interacting with sharefile programmatically}
  spec.homepage      = "https://github.com/avguchenko/sharefile-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
