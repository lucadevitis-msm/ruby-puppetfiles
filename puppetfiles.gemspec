# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puppetfiles/version'

Gem::Specification.new do |spec|
  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)
  spec.name = 'puppetfiles'
  spec.version = Puppetfiles::VERSION
  spec.authors = ['Luca De Vitis']
  spec.email = ['luca.devitis@moneysupermarket.com']

  spec.summary = 'Write a short summary'
  spec.description = 'Write a longer description'
  spec.homepage = 'http://mygemserver.com'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  spec.metadata['allowed_push_host'] = 'http://mygemserver.com'

  spec.files = `git ls-files -z`.split("\x0")
  spec.files.reject! { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
