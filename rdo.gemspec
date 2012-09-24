# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rdo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["d11wtq"]
  gem.email         = ["chris@w3style.co.uk"]

  gem.description   = <<-TEXT.strip.gsub(/^ {2}/, "")
  == Ruby Data Objects

  If you're building something in Ruby that needs access to a database, you may
  opt to use an ORM like ActiveRecord, DataMapper or Sequel. But if your needs
  don't fit well with an ORM—maybe you're even writing an ORM—then you'll
  need some other way of talking to your database.

  RDO provides a common interface to a number of RDBMS backends, using a clean
  Ruby syntax, while supporting all the functionality you'd expect from a robust
  database connection library:

  <ul>
    <li><strong>Consistent API</strong> to connect to various DBMS's</li>
    <li><strong>Type casting</strong> to Ruby types</li>
    <li><strong>Time zone handling</strong> (via the DBMS, not via some crazy
      time logic in Ruby)</li>
    <li><strong>Native bind values</strong> parameterization of queries, where
      supported by the DBMS</li>
    <li><strong>Buffered result sets</strong> (i.e. cursors, to avoid
      exhausting memory)</li>
    <li>Retrieve query info from executed commands (e.g. affected rows)</li>
    <li><strong>Access RETURNING values</strong> just like any read query</li>
    <li><strong>Native prepared statements</strong> where supported, emulated
      where not</li>
    <li>Results given using simple <strong>core Ruby data types</strong></li>
  </ul>

  == RDBMS Support

  Support for each RDBMS is provided in separate gems, so as to minimize the
  installation requirements and to facilitate the maintenace of each driver. Many
  gems are maintained by separate users who work more closely with those RDBMS's.

  Due to the nature of this gem, most of the nitty-gritty code is actually
  written in C.

  See the official README for full details.
  TEXT

  gem.summary       = "RDO—Ruby Data Objects—A robust RDBMS connection layer"
  gem.homepage      = "https://github.com/d11wtq/rdo"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rdo"
  gem.require_paths = ["lib"]
  gem.version       = RDO::VERSION

  gem.add_development_dependency "rspec"
end
