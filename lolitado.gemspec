# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lolitado/version"

Gem::Specification.new do |s|
  s.name = "lolitado"
  s.platform = Gem::Platform::RUBY
  s.version = Lolitado::VERSION
  s.date = '2018-12-14'
  s.authors = ["Dolores Zhang"]
  s.email = ["379808610@qq.com"]
  s.homepage = "http://github.com/doloreszhang/lolitado"
  s.summary = %q{Lolitado DSL for database process}
  s.description = %q{Lolitado DSL that works with Watir}
  s.files = `git ls-files`.split("\n")
  s.license = 'MIT'
  s.require_paths = ["lib"]
  s.add_dependency "sequel", "~> 5.49.0"
  s.add_dependency "net-ssh-gateway", "~> 1.2"
  s.add_dependency "httparty", "~> 0.14"
  s.add_dependency "rbnacl-libsodium", "~> 1.0.10"
end
