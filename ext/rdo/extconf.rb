require "mkmf"

if ENV["CC"]
  RbConfig::MAKEFILE_CONFIG["CC"] = ENV["CC"]
end

create_makefile("rdo/rdo")
