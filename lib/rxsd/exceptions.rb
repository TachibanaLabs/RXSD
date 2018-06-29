# frozen_string_literal: true

# RXSD exceptions
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'uri' # use uri to parse sources

# add virtual method support
class VirtualMethodCalledError < RuntimeError
  attr_reader :name
  def initialize(name)
    super("Virtual function '#{name}' called")
    @name = name
  end
end

module RXSD
  module Exceptions
    # thrown when specified resource uri is invalid
    class InvalidResourceUri
    end
    end # module Exceptions
end # module RXSD
