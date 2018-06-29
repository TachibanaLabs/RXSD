# frozen_string_literal: true

# The XSD Extension definition
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
  module XSD
    # XSD Extension defintion
    # http://www.w3schools.com/Schema/el_extension.asp
    class Extension
      # extension attributes
      attr_accessor :id, :base

      # extension group children
      attr_accessor :group, :choice, :sequence, :attributes, :attribute_groups

      # extension parent
      attr_accessor :parent

      # xml tag name
      def self.tag_name
        'extension'
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
        c
      end

      # node passed in should be a xml node representing the extension
      def self.from_xml(node)
        extension = Extension.new
        extension.parent = node.parent.related
        node.related = extension

        # TODO: extension attributes: | anyAttributes
        extension.id       = node.attrs['id']
        extension.base     = node.attrs['base']

        # TODO: extension children: | anyAttribute
        extension.group       = node.child_obj Group
        extension.choice      = node.child_obj Choice
        extension.sequence    = node.child_obj Sequence
        extension.attributes  = node.children_objs Attribute
        extension.attribute_groups = node.children_objs AttributeGroup

        extension
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

      # convert extension to class builder
      def to_class_builder(cb = nil)
        unless defined? @class_builder
          @class_builder = cb.nil? ? ClassBuilder.new : cb

          # convert extension to builder
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
        end

        @class_builder
      end

      # return all child attributes assocaited w/ extension
      def child_attributes
        atts = []
        atts += @base.child_attributes unless @base.nil? || ![SimpleType, ComplexType].include?(@base.class)
        atts += @choice.child_attributes unless @choice.nil?
        atts += @sequence.child_attributes unless @sequence.nil?
        atts += @group.child_attributes unless @group.nil?
        @attribute_groups&.each { |atg| atts += atg.child_attributes }
        @attributes&.each       { |att| atts += att.child_attributes }
        atts
      end
      end
    end # module XSD
end # module RXSD
