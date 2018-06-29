# frozen_string_literal: true

# RXSD Ruby Definition builder
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
  # Implements the RXSD::ClassBuilder interface to build string Ruby Class Definitions from xsd
  class RubyDefinitionBuilder < ClassBuilder
    # implementation of RXSD::ClassBuilder::build
    def build
      return "class #{@klass}\nend" if Parser.is_builtin? @klass

      # need the class name to build class
      return nil if @klass_name.nil?

      Logger.debug "building definition for #{@klass}/#{@klass_name}  from xsd"

      # defined class w/ base
      superclass = 'Object'
      unless @base_builder.nil?
        if    !@base_builder.klass_name.nil?
          superclass = @base_builder.klass_name
        elsif !@base_builder.klass.nil?
          superclass = @base_builder.klass.to_s
        end
      end
      res = 'class ' + @klass_name + ' < ' + superclass + "\n"

      # define accessors for attributes
      @attribute_builders.each do |atb|
        next if atb.nil?
        att_name = nil
        att_name = if !atb.attribute_name.nil?
                     atb.attribute_name.underscore
                   elsif !atb.klass_name.nil?
                     atb.klass_name.underscore
                   else
                     atb.klass.to_s.underscore
                   end

        res += "attr_accessor :#{att_name}\n"
      end
      res += 'end'

      Logger.debug "definition #{res} built, returning"
      res
    end
    end
end
