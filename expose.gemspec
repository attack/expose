# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "expose/version"

Gem::Specification.new do |s|
  s.name        = "expose"
  s.version     = Expose::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mark G"]
  s.email       = ["expose@attackcorp.com"]
  s.homepage    = "https://github.com/attack/expose"
  s.summary     = %q{Simple dynamic configuration of attr_protected}
  s.description = %q{Simple dynamic configuration of attr_protected}

  s.rubyforge_project = "expose"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("rails", "~> 3.0")
  
  s.add_development_dependency("rspec", "~> 2.6")
  s.add_development_dependency('sqlite3-ruby')
end