# frozen_string_literal: true

# The XSD Restriction definition
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
  module XSD
    # XSD Restriction defintion
    # http://www.w3schools.com/Schema/el_restriction.asp
    class Restriction
      # restriction attributes
      attr_accessor :id, :base

      # restriction group children
      attr_accessor :group, :choice, :sequence, :attributes, :attribute_groups, :simple_type

      # restrictions
      attr_accessor :min_exclusive, :min_inclusive, :max_exclusive, :max_inclusive,
                    :total_digits, :fraction_digits, :length, :min_length, :max_length,
                    :enumerations, :whitespace, :pattern

      # restriction parent
      attr_accessor :parent

      # xml tag name
      def self.tag_name
        'restriction'
      end

      # return xsd node info
      def info
        "extension id: #{@id} base: #{@base.nil? ? '' : @base.class == String || Parser.is_builtin?(@base) ? @base : @base.name}"
      end

      # returns array of all children
      def children
        c = []
        c.push @group  unless @group.nil?
        c.push @choice unless @choice.nil?
        c.push @sequence unless @sequence.nil?
        c += @attributes unless @attributes.nil?
        c += @attribute_groups unless @attribute_groups.nil?
        c.push @simple_type unless @simple_type.nil?
        c
      end

      # node passed in should be a xml node representing the restriction
      def self.from_xml(node)
        restriction = Restriction.new
        restriction.parent = node.parent.related
        node.related = restriction

        # TODO: restriction attributes: | anyAttributes
        restriction.id       = node.attrs['id']
        restriction.base     = node.attrs['base']

        if node.parent.name == ComplexContent.tag_name
          # TODO: restriction children: | anyAttribute
          restriction.group       = node.child_obj Group
          restriction.choice      = node.child_obj Choice
          restriction.sequence    = node.child_obj Sequence
          restriction.attributes  = node.children_objs Attribute
          restriction.attribute_groups = node.children_objs AttributeGroup

        elsif node.parent.name == SimpleContent.tag_name
          # TODO: restriction children: | anyAttribute
          restriction.attributes       = node.children_objs Attribute
          restriction.attribute_groups = node.children_objs AttributeGroup
          restriction.simple_type = node.child_obj SimpleType
          parse_restrictions(restriction, node)

        else # SimpleType
          restriction.attributes              = []
          restriction.attribute_groups        = []
          restriction.simple_type = node.child_obj SimpleType
          parse_restrictions(restriction, node)

        end

        restriction
      end

      # resolve hanging references given complete xsd node object array
      def resolve(node_objs)
        unless @base.nil?
          builtin  = Parser.parse_builtin_type @base
          simple   = node_objs[SimpleType].find  { |no| no.name == @base }
          complex  = node_objs[ComplexType].find { |no| no.name == @base }
          if !builtin.nil?
            @base = builtin
          elsif !simple.nil?
            @base = simple
          elsif !complex.nil?
            @base = complex
          end
        end
      end

      # convert restriction to class builder
      def to_class_builder(cb = nil)
        unless defined? @class_builder
          @class_builder = cb.nil? ? ClassBuilder.new : cb

          # convert restriction to builder
          if Parser.is_builtin? @base
            @class_builder.base = @base
          elsif !@base.nil?
            @class_builder.base_builder = @base.to_class_builder
          end

          @group&.to_class_builders&.each do |gcb|
            @class_builder.attribute_builders.push gcb
          end

          @choice&.to_class_builders&.each do |ccb|
            @class_builder.attribute_builders.push ccb
          end

          @sequence&.to_class_builders&.each do |scb|
            @class_builder.attribute_builders.push scb
          end

          @attributes.each do |att|
            @class_builder.attribute_builders.push att.to_class_builder
          end

          @attribute_groups.each do |atg|
            atg.to_class_builders.each do |atcb|
              @class_builder.attribute_builders.push atcb
            end
          end

          unless @simple_type.nil?
            @class_builder.attribute_builders.push @simple_type.to_class_builder
          end

          # FIXME: add facets
        end

        @class_builder
      end

      # return all child attributes assocaited w/ restriction
      def child_attributes
        atts = []
        atts += @base.child_attributes unless @base.nil? || ![SimpleType, ComplexType].include?(@base.class)
        atts += @sequence.child_attributes unless @sequence.nil?
        atts += @choice.child_attributes unless @choice.nil?
        atts += @group.child_attributes  unless @group.nil?
        atts += @simple_type.child_attributes unless @simple_type.nil?
        @attribute_groups&.each { |atg| atts += atg.child_attributes }
        @attributes&.each       { |att| atts += att.child_attributes }
        atts
      end

      private

      # internal helper method
      def self.parse_restrictions(restriction, node)
        restriction.min_exclusive = node.child_value('minExclusive').to_i
        restriction.min_inclusive = node.child_value('minInclusive').to_i
        restriction.max_exclusive = node.child_value('maxExclusive').to_i
        restriction.max_inclusive = node.child_value('maxInclusive').to_i
        restriction.total_digits  = node.child_value('totalDigits').to_i
        restriction.fraction_digits = node.child_value('fractionDigits').to_i
        restriction.length        = node.child_value('length').to_i
        restriction.min_length    = node.child_value('minLength').to_i
        restriction.max_length    = node.child_value('maxLength').to_i
        restriction.enumerations  = node.child_values 'enumeration'
        restriction.whitespace    = node.child_value 'whitespace'
        restriction.pattern       = node.child_value 'pattern'
      end
      end
    end # module XSD
end # module RXSD
