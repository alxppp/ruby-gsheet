# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gsheet/version"

Gem::Specification.new do |spec|
  spec.name          = "gsheet"
  spec.version       = Gsheet::VERSION
  spec.authors       = ["Alexander Popp"]
  spec.email         = ["alxppp@googlemail.com"]

  spec.summary       = 'Use GSuite sheets as arrays or hashes'
  spec.description   = 'This gem two-way binds Google sheets by providing a Ruby array and hash like interface.'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "docs.google.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '~> 4.2.5'
  spec.add_dependency 'facets'
  spec.add_dependency 'google_drive'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
