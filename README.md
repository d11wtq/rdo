# RDO—Ruby Data Objects

RDO provides a simple, robust standardized way to access various RDBMS
implementations in Ruby. Drivers all conform to the same, beautiful rubyesque
interface. Where a feature is not natively supported by the DBMS—for example,
prepared statements—it is seamlessly emulated, so you don't need to code
around it.

``` ruby
require "rdo"
require "rdo-postgres"

conn = RDO.connect("postgres://user:pass@localhost/dbname?encoding=utf-8")

result = conn.execute(
  "INSERT INTO users (
    username, password_hash, created_at, updated_at
  ) VALUES (?, ?, ?, ?) RETURNING id",
  'bob',
  Digest::MD5.hexdigest('secret'),
  Time.now,
  Time.now
)

puts "Inserted user ID = #{result.insert_id}"

result = conn.execute("SELECT * FROM users WHERE username LIKE ?", "%jim%")
result.each do |row|
  puts "#{row[:id]}: #{row[:username]}"
end

conn.close
```

## What is it not?

RDO provides access to a number of RDBMS's. It allows you to query using SQL
and issue commands using DDL, as thinly as is necessary. It is absolutely not,
nor is it trying to be an SQL abstraction layer, an ORM or anything of that
nature. The intention is to provide a way to allow Ruby developers to write
applications that use a database, but don't use an ORM (*scoff!*).

Or perhaps you're actually writing the next kick-ass ORM? Either way, RDO
just talks lets you talk directly to your database.

## What features do it provide?

Let's face it, we've been writing database applications since the dark ages—
it's not that hard. What's lacking from Ruby, however, is any consistency for
dealing with a database directly. Several beautiful ORMs exist, but they
serve a different need. DataMapper has a layer underneath it called
data_objects, but it isn't particularly user-friendly when used standalone
and it requires jumping through hoops to deal with certain database RDBMS
features—`bytea` fields, for example, must be wrapped in ByteArray objects
so that its quoting logic can escape the value correctly. Postgres actually
provides support for such things transparently at the C layer. It should not
have to be this way. RDO makes the best use of the C APIs provided by the
RDBMS vendors that it can.

The following features are a standard part of the API for RDO:

  - **Consistent** class/method contracts for all drivers
  - **Native bind parameters** where possible; emulated where not
  - **Prepared statements** where possible; emulated where not
  - **Type-casting** to equivalent Ruby types (e.g. Fixnum, BigDecimal,
    Float, even Array)
  - **Buffered result sets** where possible–enumerate millions of rows
    without memory issues
  - Access meta data after write operations, with insert IDs standardized
  - **Use simple core data types** (Hash) for reading values and field names

## Installation

RDO doesn't do anything by itself. You need to also install the driver for
your DBMS. Install via Rubygems.

    $ gem install rdo
    $ gem install rdo-postgres

Or add a line to your application's Gemfile:

    gem "rdo"
    gem "rdo-postgres"

And then execute:

    $ bundle

## Contributing

The more drivers that RDO has support for, the better. Writing drivers for
RDO is quite painless. They are just thin wrappers around the C API for the
DBMS, which conform to RDO's interface. Take a look at one of the existing
drivers to get an idea how to do that. Because one person could not possibly
maintain drivers for all conceivable DBMS's, it is better that different
developers write and maintain different drivers. If you have written a driver
for RDO, however, please edit this README to list it. That way others will
find it more easily.

If you find a bug in RDO, send a pull request if you think you can fix it.
Your contribution will be recognized here. If you don't know how to fix it,
file an issue in the issue tracker on GitHub.

When sending pull requests, please use topic branches—don't send a pull
request from the master branch of your fork, as that may change
unintentionally.

## Copyright & Licensing

Written and maintained by Chris Corbyn.

Licensed under the MIT license. That pretty much means it's fair game to use
RDO as you please, but you should refer to the LICENSE file for details.
