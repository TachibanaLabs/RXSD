# frozen_string_literal: true

# The XSD ComplexType definition
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
  module XSD
    # XSD ComplexType defintion
    # http://www.w3schools.com/Schema/el_simpletype.asp
    class ComplexType
      # complex type attribute values
      attr_accessor :id, :name, :abstract, :mixed

      # complex type children
      attr_accessor :attributes, :attribute_groups,
                    :simple_content, :complex_content,
                    :choice, :group, :sequence

      # complexType parent
      attr_accessor :parent

      # xml tag name
      def self.tag_name
        'complexType'
      end

      # return xsd node info
      def info
        "complexType id: #{@id} name: #{@name}"
      end

      # returns array of all children
      def children
        (@attributes + @attribute_groups).push(@simple_content)
                                         .push(@complex_content).push(@choice).push(@group).push(@sequence)
      end

      # node passed in should be a xml node representing the complex type
      def self.from_xml(node)
        complexType = ComplexType.new
        complexType.parent = node.parent.related
        node.related = complexType

        # TODO: complexType attributes: | block, final, anyAttributes

        complexType.id       = node.attrs['id']
        complexType.name     = node.attrs['name']
        complexType.abstract = node.attrs.key?('abstract') ? node.attrs['abstract'].to_b : false

        if node.children.find { |c| c.name == SimpleContent.tag_name }.nil?
          complexType.mixed = node.attrs.key?('mixed') ? node.attrs['mixed'].to_b : false
        else
          complexType.mixed = false
        end

        # TODO: complexType children: | all, anyAttribute,
        complexType.attributes       = node.children_objs Attribute
        complexType.attribute_groups = node.children_objs AttributeGroup
        complexType.simple_content   = node.child_obj SimpleContent
        complexType.complex_content  = node.child_obj ComplexContent
        complexType.group            = node.child_obj Group
        complexType.choice           = node.child_obj Choice
        complexType.sequence         = node.child_obj Sequence

        complexType
      end

      # resolve hanging references given complete xsd node object array
      def resolve(node_objs); end

      # convert complex type to class builder
      def to_class_builder
        unless defined? @class_builder
          # dispatch to simple / complex content to get class builder
          @class_builder = ClassBuilder.new

          if !@simple_content.nil?
            @simple_content.to_class_builder(@class_builder)
          elsif !@complex_content.nil?
            @complex_content.to_class_builder(@class_builder)
            # else
            # @class_builder = ClassBuilder.new
          end

          @class_builder.klass_name = @name.camelize unless @name.nil?

          @attributes.each do |att|
            @class_builder.attribute_builders.push att.to_class_builder
          end
          @attribute_groups.each do |atg|
            atg.to_class_builders.each do |atcb|
              @class_builder.attribute_builders.push atcb
            end
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
        end

        @class_builder
      end

      # return all child attributes assocaited w/ complex type
      def child_attributes
        atts = []
        atts += @choice.child_attributes unless @choice.nil?
        atts += @sequence.child_attributes unless @sequence.nil?
        atts += @group.child_attributes unless @group.nil?
        atts += @simple_content.child_attributes unless @simple_content.nil?
        atts += @complex_content.child_attributes unless @complex_content.nil?
        @attribute_groups&.each { |atg| atts += atg.child_attributes }
        @attributes&.each       { |att| atts += att.child_attributes }
        atts
      end
      end
    end # module XSD
end # module RXSD
