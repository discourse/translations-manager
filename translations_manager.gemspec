# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'translations_manager/version'

Gem::Specification.new do |spec|
  spec.name          = "translations-manager"
  spec.version       = TranslationsManager::VERSION
  spec.authors       = ["Neil Lalonde"]
  spec.email         = ["neil.lalonde@discourse.org"]

  spec.summary       = %q{Tools used to update translations in Discourse repos}
  spec.description   = %q{We need to update translations in different repos for our official plugins, so use this gem.}
  spec.homepage      = "https://github.com/discourse/translations-manager"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
