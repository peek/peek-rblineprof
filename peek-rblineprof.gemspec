# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'peek-rblineprof/version'

Gem::Specification.new do |spec|
  spec.name          = 'peek-rblineprof'
  spec.version       = Peek::Rblineprof::VERSION
  spec.authors       = ['Garrett Bjerkhoel']
  spec.email         = ['me@garrettbjerkhoel.com']
  spec.description   = %q{Peek into how much each line of your Rails application takes throughout a request.}
  spec.summary       = %q{Peek into how much each line of your Rails application takes throughout a request.}
  spec.homepage      = 'https://github.com/peek/peek-rblineprof'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'peek'
  spec.add_dependency 'rblineprof'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
