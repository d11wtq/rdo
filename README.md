# RDO—Database Connectivity for Ruby

RDO provides a simple, robust standardized way to access various RDBMS
implementations in Ruby. Drivers all conform to the same, beautiful rubyesque
interface. Where a feature is not natively supported by the DBMS—perhaps
prepared statements—it is seamlessly emulated, so you don't need to code
around it.

It targets **Ruby 1.9** and newer (including Rubinius 2.0).

[![Build Status](https://secure.travis-ci.org/d11wtq/rdo.png?branch=master)](http://travis-ci.org/d11wtq/rdo)

**RDO** stands for Ruby Data Objects.

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

## Features

RDO makes the following things standard:

  - **Consistent** class/method contracts for all drivers
  - **Native bind parameters** where possible; emulated where not
  - **Prepared statements** where possible; emulated where not
  - **Type-casting** to equivalent Ruby types (e.g. Fixnum, BigDecimal,
    Float, even Array)
  - Access result information after write operations, with insert IDs standardized
  - **Use simple core data types** (Hash) for reading values and field names

Note that data-type support is limited to whatever the DBMS actually supports.
See individual driver READMEs for type support information.

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
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>SQLite</th>
      <td>sqlite, sqlite3</td>
      <td><a href="https://github.com/d11wtq/rdo-sqlite">rdo-sqlite</a></td>
      <td><a href="https://github.com/d11wtq">d11wtq</a></td>
      <td>
        <img src="https://secure.travis-ci.org/d11wtq/rdo-sqlite.png?branch=master"
          alt="Build Status" title="Build Status" />
      </td>
    </tr>
    <tr>
      <th>PostgreSQL</th>
      <td>postgresql, postgres</td>
      <td><a href="https://github.com/d11wtq/rdo-postgres">rdo-postgres</a></td>
      <td><a href="https://github.com/d11wtq">d11wtq</a></td>
      <td>
        <img src="https://secure.travis-ci.org/d11wtq/rdo-postgres.png?branch=master"
          alt="Build Status" title="Build Status" />
      </td>
    </tr>
    <tr>
      <th>MySQL</th>
      <td>mysql</td>
      <td><a href="https://github.com/d11wtq/rdo-mysql">rdo-mysql</a></td>
      <td><a href="https://github.com/d11wtq">d11wtq</a></td>
      <td>
        <img src="https://secure.travis-ci.org/d11wtq/rdo-mysql.png?branch=master"
          alt="Build Status" title="Build Status" />
      </td>
    </tr>
  </tbody>
</table>

I'm looking for contributors to develop and maintain drivers for other vendors:
Oracle, SQL Server and DB2 are of interest. Your project would be linked above.

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

For semantic reasons, #connect is aliased to #open.

If it is not possible to establish a connection an RDO::Exception is raised,
which should provide any reason given by the DBMS.

You can also pass a block to #connect. This has the same semantics as passing
a block to File#open (i.e. it passes itself to the block, returns the value
of the block and finally closes the connection).

### Disconnecting

RDO will disconnect automatically when the connection is garbage-collected,
or when the program exits, but if you need to disconnect explicitly,
call #close. It is safe to call this even if the connection is already closed.

If you have called #close, say before forking, call #open to re-connect.

``` ruby
conn.close
p conn.open? #=> false

conn.open
p conn.open? #=> true
```

### Performing non-read commands

Any command supported by the DBMS is executed with #execute, which always
returns a RDO::Result object. Query inputs should be provided as binding
placeholders and additional arguments. No explicit type-conversion is
necessary.

``` ruby
result = conn.execute("CREATE TABLE bob ( ... )")
result = conn.execute("UPDATE users SET banned = ?", true)

p result.affected_rows #=> 5087

result = conn.execute(
  "INSERT INTO users (name, created_at) VALUES (?, ?) RETURNING id",
  "Jimbo Baggins",
  Time.now
)

p result.insert_id       #=> 5088
p result.execution_time  #=> 0.0000587

# fields from the RETURNING clause are included in the result, like a SELECT
result.each do |row|
  p row[:id] #=> 5088
end
```

In the event of a query error, an RDO::Exception is raised, which should
include any error messaage provided by the DBMS.

### Performing read queries

There is no difference in the interface for reads or writes. Just call
the #execute method in both cases. This always returns an RDO::Result,
which includes the Enumerable module. Some operations, such as #count
may be optimized by the driver.

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

While driver developers are expected to provide a suitable implementation,
it is generally riskier to escape and interpolate inputs directly into the
SQL than it is to use bind parameters. There are times where you might
need to escape some input yourself, however. For that, you can call #quote.

``` ruby
conn.execute("INSERT INTO users (name) VALUES ('#{conn.quote(params[:name])}')")
```

### Column names with whitespace in them

RDO uses Symbols as keys in the hashes that represent data rows. Most of the
time this is desirable. If you query for something that returns field names
containing spaces, or punctuation, you need to convert a String to a Symbol
using #to_sym or #intern. Or use a quoted Symbol-literal.

``` ruby
result = conn(%q{SELECT 42 AS "The Meaning"})
p result.first[:"The Meaning"]
p result.first["The Meaning".intern]
```

### Selecting just a single value

RDO::Result has a #first_value method for convenience if you are only
selecting one row and one column.

``` ruby
p conn.execute("SELECT count(true) FROM users").first_value #=> 5088
```

This method returns nil if there are no rows, so if you need to distinguish
between NULL and no rows, you will need to check the result contents the
longer way around.

### Disambiguating bind markers from operators

Some drivers use '?' for operators. In order to avoid ambiguity, escape such
occurrences with a backslash. You **do not** need to escape inside of strings
and comments (i.e. wherever a bind marker could not naturally occur).

``` ruby
conn.execute(%q{SELECT 'a=>42,b=>7'::hstore \? ?}, "a")
```

### Debugging

A Logger instance (with an interface like that in Ruby stdlib) may be passed
in the options when creating a connection. All queries will be logged with
DEBUG severity. Errors will be logged with FATAL severity.

``` ruby
RDO.connect("postgres://user:pass@host/db", logger: Logger.new(STDOUT))
```

You can access the logger through `connection.logger`.

``` ruby
conn.logger.level = Logger::DEBUG
conn.logger.debug? #=> true
```

A logger with some support for highlighting errors etc and which shows
query execution times is configured (but disabled) by default. It is
found at `RDO::ColoredLogger`. You can enable it by specify a log level:

``` ruby
RDO.connect("postgres://user:pass@host/db", log_level: Logger::DEBUG)
```

If you want the log output to go somewhere other than stdout, instantiate
the logger manually.

### Temporary debug output

Turning on debug logging globally is often a little overkill and too noisy.
You may enable debug logging in the context of a block, like so:

``` ruby
conn.debug do
  # call some methods that execute SQL
end
```

The log level will be restored after the block has executed, even if an
Exception is raised.

## Contributing

If you find a bug in RDO, send a pull request if you think you can fix it.
Your contribution will be recognized here. If you don't know how to fix it,
file an issue in the issue tracker on GitHub.

When sending pull requests, please use topic branches—don't send a pull
request from the master branch of your fork.

I haven't looked at what I need to change to have the drivers compile on
Windows yet, but I will do. If anybody beats me to it, pull requests will
be gladly accepted! I was going to write JDBC wrappers for JRuby, but have
decided to just aim for JRuby >= 1.6, which supports C extensions. This
hasn't yet been tested with RDO. I should be able to make it work, as the
parts of the Ruby API I use are very typical.

### Writing a driver for RDO

The more drivers that RDO has support for, the better. Writing drivers for
RDO is quite painless. They are just thin wrappers around the C API for the
DBMS, which conform to RDO's Driver interface.

```
RDO::Driver
  - open
  - open?
  - close
  - execute
  - prepare
  - quote
```

The #execute method returns an RDO::Result, which takes any Enumerable and
some options in its initializer. The Enumerable just iterates over the rows
in the result. The options Hash provides result information.

The #prepare method is optional, but should return an Object with the
following methods:

```
RDO::StatementExecutor
  - command
  - execute
```

The #command method just provides the String form of the statement. The #execute
method returns an RDO::Result, as per the Driver.

Some of the more boilerplate things you'd normally have to do are covered by
C macros in the util/macros.h file you'll find in this repository. Copy that
file to your own project and include it for one-line type conversions etc.
Take a look at one of the existing drivers to get an idea how to write a
driver (rdo-sqlite and rdo-mysql are probably simple ones).

## Copyright & Licensing

Written and maintained by Chris Corbyn.

Licensed under the MIT license. That pretty much means it's fair game to use
RDO as you please, but you should refer to the LICENSE file for details.
