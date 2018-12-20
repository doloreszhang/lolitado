# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

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
  s.files = Dir['lib/*.rb']
  s.license = 'MIT'
  s.require_paths = ["lib"]
  s.add_dependency "mysql2", "~> 0.4"
  s.add_dependency "sequel", "~> 4.37"
  s.add_dependency "net-ssh-gateway", "~> 1.2"
  s.add_dependency "httparty", "~> 0.14"
end
