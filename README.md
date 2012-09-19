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
    name, password_hash, created_at, updated_at
  ) VALUES (?, ?, ?, ?) RETURNING id",
  'bob',
  Digest::MD5.hexdigest('secret'),
  Time.now,
  Time.now
)

puts "Inserted user ID = #{result.insert_id}"

result = conn.execute("SELECT * FROM users WHERE name LIKE ?", "%jim%")
result.each do |row|
  puts "#{row[:id]}: #{row[:name]}"
end

conn.close
```

## Why your ORM so shit?

RDO provides access to a number of RDBMS's. It allows you to query using SQL
and issue commands using DDL, as thinly as is necessary. It is absolutely not,
nor is it trying to be an SQL abstraction layer, an ORM or anything of that
nature. The intention is to provide a way to allow Ruby developers to write
applications that use a database, but don't use an ORM (*scoff!*).

Or perhaps you're actually writing the next kick-ass ORM? Either way, RDO
just lets you talk directly to your database.

## Meh, what does it provide?

Let's face it, we've been writing database applications since the dark ages—
it's not that hard. What's lacking from Ruby, however, is any consistency for
dealing with a database directly. Several beautiful ORMs exist, but they
serve a different need. [DataMapper](https://github.com/datamapper/dm-core)
has a layer underneath it called [data_objects](https://github.com/datamapper/do),
but it isn't particularly user-friendly when used standalone and it requires
jumping through hoops to deal with certain database RDBMS features, such as
PostgreSQL bytea fields.

RDO makes the following things standard:

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

## Available Drivers

<table>
  <thead>
    <tr>
      <th>Database Vendor</th>
      <th>URI Schemes</th>
      <th>Gem</th>
      <th>Author</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>SQLite</th>
      <td>sqlite</td>
      <td><a href="https://github.com/d11wtq/rdo-sqlite">rdo-sqlite</a></td>
      <td><a href="https://github.com/d11wtq">d11wtq</a></td>
    </tr>
    <tr>
      <th>PostgreSQL</th>
      <td>postgresql, postgres</td>
      <td><a href="https://github.com/d11wtq/rdo-postgres">rdo-postgres</a></td>
      <td><a href="https://github.com/d11wtq">d11wtq</a></td>
    </tr>
    <tr>
      <th>MySQL</th>
      <td>mysql</td>
      <td><a href="https://github.com/d11wtq/rdo-mysql">rdo-mysql</a></td>
      <td><a href="https://github.com/d11wtq">d11wtq</a></td>
    </tr>
  </tbody>
</table>

## Usage

The interface for RDO is intentionally minimal. It should take a few minutes
to learn just about everything.

### Connecting to a database

A connection is established when you initialize an RDO::Connection. The
easiest way to do that is through `RDO.connect`. Make sure you have required
the driver for RDO first, or it will explode, like, all in your face and stuff.

``` ruby
require "rdo"
require "rdo-postgres"

conn = RDO.connect("postgresql://user:pass@host:port/db_name?encoding=utf-8")
p conn.open? #=> true
```

If it is not possible to establish a connection an RDO::Exception is raised,
which should provide any reason given by the DBMS.

### Disconnecting

RDO will disconnect automatically when the connection is garbage-collected,
or when the program exits, but if you need to disconnect explicitly,
call #close. It is safe to call this even if the connection is already closed.

Call #open to re-connect after closing a connection, for example when forking
child processes.

``` ruby
conn.close
p conn.open? #=> false

conn.open
p conn.open? #=> true
```

### Performing non-read commands

All SQL and DDL (Data Definition Language) is executed with #execute, which
always returns a RDO::Result object. Query inputs should be provided as
binding placeholders and additional arguments. No explicit type-conversion is
necessary.

``` ruby
result = conn.execute("CREATE TABLE bob ( ... )")
result = conn.execute("UPDATE users SET banned = ?", true)

p result.affected_rows #=> 5087

result = conn.execute(
  "INSERT INTO users (name, created_at) VALUES (?, ?) RETURNING id",
  "Jimbo Baggins"
)

p result.insert_id       #=> 5088
p result.execution_time  #=> 0.0000587

# the RETURNING clause is passed by in the result, like a read query
result.each do |row|
  p row[:id] #=> 5088
end
```

In the event of a query error, an RDO::Exception is raised, which should
include any error messaage provided by the DBMS.

### Performing read queries

There is no difference in the interface for reads or writes. Just call
the #execute method—which always returns a RDO::Result—for both.
RDO::Result includes the Enumerable module.

``` ruby
result = conn.execute("SELECT id, name FROM users WHERE created_at > ?", 1.week.ago)

p result.count #=> 120

result.each do |row|
  p "#{row[:id]}: #{row[:name]}"
end
```

In the event of a query error, an RDO::Exception is raised, which should
include any error messaage provided by the DBMS.

### Using prepared statements

Most mainstream databases support them. Some don't, but RDO emulates them in
that case. Prepared statements provide safety through bind parameters and
efficiency through query re-use, because the query planner only executes once.

Prepare a statement with #prepare, then execute it with #execute, passing in
any bind parameters. An RDO::Result is returned.

``` ruby
stmt = conn.prepare("SELECT * FROM users WHERE name LIKE ? AND banned = ?")

%w[bob jim harry].each do |name|
  result = stmt.execute("%#{name}%", false)
  result.each do |row|
    p "#{row[:id]: row[:name]}"
  end
end
```

RDO simply delegates to #execute if the driver doesn't support prepared
statements.

In the event of a query error, an RDO::Exception is raised, which should
include any error messaage provided by the DBMS.

### Tread carefully, there be danger ahead

While driver developers are expected to provide a suitable implememtation,
it is generally riskier to use #quote and interpolate inputs directly into
the SQL, than to use bind parameters. There are times where you might need
to escape some input yourself, however. For that, you can call #quote.

``` ruby
conn.execute("INSERT INTO users (name) VALUES ('#{conn.quote(params[:name])}')")
```

### Column names with whitepsace in them

RDO uses Symbols as keys in the hashes that represent data rows. Most of the
time this is desirable. If you query for something that returns field names
containing spaces, or punctation, you need to convert a String to a Symbol
using #to_sym or #intern. Or wrap the Hash with a Mash of some sort.

``` ruby
result = conn(%q{SELECT 42 AS "The Meaning"})
p result.first["The Meaning".intern]
```

I weighed up the possibility of using a custom data type, but I prefer core
ruby types unless there's an overwhelming reason to use a custom type, sorry.

## Contributing

The more drivers that RDO has support for, the better. Writing drivers for
RDO is quite painless. They are just thin wrappers around the C API for the
DBMS, which conform to RDO's interface. Take a look at one of the existing
drivers to get an idea how to do that. Because one person could not possibly
maintain drivers for all conceivable DBMS's, it is better that different
developers write and maintain different drivers. If you have written a driver
for RDO, please fork this git repo and edit this README to list it, then send
a pull request. That way others will find it more easily.

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
