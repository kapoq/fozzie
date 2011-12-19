# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fozzie/version"

Gem::Specification.new do |s|
  s.name        = "fozzie"
  s.version     = Fozzie::VERSION
  s.authors     = ["Marc Watts"]
  s.email       = ["marcw.watts@loneplanet.com"]
  s.summary     = %q{Statistics gem for LonelyPlanet Online}
  s.description = %q{Gem allows statistics gathering from Ruby and Ruby 
    on Rails applications within LonelyPlanet Online}

  s.rubyforge_project = "fozzie"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'rake'
  s.add_development_dependency "rspec"
  s.add_development_dependency "mocha"
  s.add_development_dependency "simplecov"
end
