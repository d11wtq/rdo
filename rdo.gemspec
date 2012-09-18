# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rdo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["d11wtq"]
  gem.email         = ["chris@w3style.co.uk"]

  gem.description   = <<-TEXT.strip.gsub(/^ {2}/, "")
  == Ruby Data Objects

  If you're building something in Ruby that needs access to a database, you may
  opt to use an ORM like ActiveRecord, DataMapper or Sequel. If your needs
  don't fit well with an ORM (maybe you're even writing an ORM?) then you'll
  need some other way of talking to your database.

  RDO provides a common interface to a number of RDBMS backends, using a clean
  Ruby syntax, while supporting all the functionality you'd expect from a robust
  database connection library:

    - Connect to different types of RDBMS
    - Type casting
    - Safe parameterization of queries
    - Buffered query results
    - Fetching meta data from executed commands
    - Prepared statements (either native, or emulated where no native support exists)
    - Connection pooling
    - Convenient access to queried data

  === RDBMS Support

  Support for each RDBMS is provide in separate gems, so as to minimize the
  installation requirements. Many gems are maintained by separate users who
  work with those RDBMS's, but they are listed below:

  <table>
    <thead>
      <tr>
        <th>DBMS</th>
        <th>Project</th>
        <th>Author</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>SQLite</td>
        <td>https://github.com/d11wtq/rdo-sqlite</td>
        <td>d11wtq (Chris Corbyn)</td>
      </tr>
      <tr>
        <td>PostgreSQL</td>
        <td>https://github.com/d11wtq/rdo-postgres</td>
        <td>d11wtq (Chris Corbyn)</td>
      </tr>
      <tr>
        <td>MySQL</td>
        <td>https://github.com/d11wtq/rdo-mysql</td>
        <td>d11wtq (Chris Corbyn)</td>
      </tr>
    </tbody>
  </table>

  See the official README for full details.
  TEXT

  gem.summary       = "Ruby Data Objects—A Really simple multi-RDBMS connection layer"
  gem.homepage      = "https://github.com/d11wtq/rdo"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rdo"
  gem.require_paths = ["lib"]
  gem.version       = RDO::VERSION

  gem.add_development_dependency "rspec"
end
