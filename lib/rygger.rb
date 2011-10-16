require_relative "rygger/version"
require_relative 'rygger/color_assigner'
require_relative 'rygger/rfind'
require_relative 'rygger/rgrep'
require_relative 'rygger/utils'

if RUBY_VERSION =~ /1.9/
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
end

module Rygger
  # Your code goes here...
end
