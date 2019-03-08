
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sequins/version"

Gem::Specification.new do |spec|
  spec.name          = "sequins"
  spec.version       = Sequins::VERSION
  spec.authors       = ["Pete Keen"]
  spec.email         = ["pete@petekeen.net"]

  spec.summary       = %q{Sequins allows you to define temporal sequences of actions}
  spec.description   = %q{Set up sequences of actions that are delayed in time}
  spec.homepage      = "https://github.com/peterkeen/sequins"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "docile"
  spec.add_dependency "tod"
  spec.add_dependency "autoloaded", "~> 2"
  spec.add_dependency "rails", ">= 5.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rspec-rails", "~> 3.5"
  spec.add_development_dependency "timecop"
end
