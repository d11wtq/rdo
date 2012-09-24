# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rdo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["d11wtq"]
  gem.email         = ["chris@w3style.co.uk"]

  gem.description   = <<-TEXT.strip.gsub(/^ {2}/, "")
  == Ruby Data Objects

  If you're building something in Ruby that needs access to a database, you may
  opt to use an ORM like ActiveRecord, DataMapper or Sequel. But if your needs
  don't fit well with an ORM (maybe you're even writing an ORM?) then you'll
  need some other way of talking to your database.

  RDO provides a common interface to a number of RDBMS backends, using a clean
  Ruby syntax, while supporting all the functionality you'd expect from a robust
  database connection library:

   * __Consistent API__ to connect to various DBMS's
   * __Type casting__ to Ruby types
   * __Time zone handling__ (via the DBMS, not via some crazy time logic in Ruby)
   * __Native bind values__ parameterization of queries, where supported by the DBMS
   * __Buffered result sets__ (i.e. cursors, to avoid exhausting memory)
   * Retrieve query info from executed commands (e.g. affected rows)
   * __Access RETURNING values__ just like any read query
   * __Native prepared statements__ where supported, emulated where not
   * Results given using simple __core Ruby data types__

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
