# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arel_search/version'

Gem::Specification.new do |gem|
  gem.name          = "arel_search"
  gem.version       = ArelSearch::VERSION
  gem.authors       = ["Marcus Vinicius Loureiro Mansur"]
  gem.email         = ["marcus.v.mansur@gmail.com"]
  gem.description   = %q{Arel based search gem}
  gem.summary       = %q{Searching becomes easy with ArelSearch}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
