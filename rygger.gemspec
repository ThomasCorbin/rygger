# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rygger/version"

Gem::Specification.new do |s|
  s.name        = "rygger"
  s.version     = Rygger::VERSION
  s.authors     = ["Thomas Corbin"]
  s.email       = ["thomas.corbin@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Command line utilities, primarily meant for Windows w/o cygwin}
  s.description = %q{Command line utilities to replace common unix commands, such as grep, find, etc.}

  s.rubyforge_project = "rygger"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency  "rspec"
  s.add_development_dependency  "rocco"

  s.add_runtime_dependency      'colorize'
  s.add_runtime_dependency      'hirb'
  s.add_runtime_dependency      'lolize'
  s.add_runtime_dependency      'ptools'
  s.add_runtime_dependency      'rake'
  s.add_runtime_dependency      'slop'
  # s.add_runtime_dependency      'iconv'
  s.add_runtime_dependency      'file-tail'
end
