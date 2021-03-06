# frozen_string_literal: true

# loads and runs all tests for the rxsd project
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# Licensed under the AGPLv3+ http://www.gnu.org/licenses/agpl.txt

require 'rspec'

CURRENT_DIR = File.dirname(__FILE__)
$LOAD_PATH << File.expand_path(CURRENT_DIR + '/../lib')

require 'rxsd'
include RXSD
include RXSD::XSD
