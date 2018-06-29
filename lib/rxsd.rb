# frozen_string_literal: true

# include all rxsd modules
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

lib = File.dirname(__FILE__)

$LOAD_PATH << lib + '/rxsd/'

require 'rubygems'

require lib + '/rxsd/exceptions'
require lib + '/rxsd/common'
require lib + '/rxsd/builtin_types'
require lib + '/rxsd/xml'
require lib + '/rxsd/loader'
require lib + '/rxsd/resolver'
require lib + '/rxsd/parser'
require lib + '/rxsd/builder'
require lib + '/rxsd/translator'

Dir[lib + '/rxsd/xsd/*.rb'].each { |xsd_module| require xsd_module }
