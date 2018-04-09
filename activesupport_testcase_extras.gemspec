
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "activesupport_testcase_extras/version"

Gem::Specification.new do |spec|
  spec.name          = "activesupport_testcase_extras"
  spec.version       = ActivesupportTestcaseExtras::VERSION
  spec.authors       = ["Beau Barker"]
  spec.email         = ["beau@barkerest.com"]

  spec.summary       = "Provides some additional test methods to ActiveSupport::TestCase."
  spec.homepage      = "https://github.com/barkerest/activesupport_testcase_extras"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'active_support',       '>= 4.0'

  spec.add_development_dependency "bundler",  "~> 1.16"
  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
