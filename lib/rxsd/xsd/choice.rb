# frozen_string_literal: true

# The XSD Choice definition
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
  module XSD
    # XSD Choice defintion
    # http://www.w3schools.com/Schema/el_choice.asp
    class Choice
      # choice attributes
      attr_accessor :id, :maxOccurs, :minOccurs

      # choice children
      attr_accessor :elements, :groups, :choices, :sequences

      # choice parent
      attr_accessor :parent

      # xml tag name
      def self.tag_name
        'choice'
      end

      # return xsd node info
      def info
        "choice id: #{@id}"
      end

      # returns array of all children
      def children
        @elements + @groups + @choices + @sequences
      end

      # node passed in should be a xml node representing the group
      def self.from_xml(node)
        choice = Choice.new
        choice.parent = node.parent.related
        node.related = choice

        # TODO: choice attributes: | anyAttributes
        choice.id = node.attrs['id']

        choice.maxOccurs  = node.attrs.key?('maxOccurs') ?
                                 (node.attrs['maxOccurs'] == 'unbounded' ? 'unbounded' : node.attrs['maxOccurs'].to_i) : 1
        choice.minOccurs  = node.attrs.key?('minOccurs') ?
                                 (node.attrs['minOccurs'] == 'unbounded' ? 'unbounded' : node.attrs['minOccurs'].to_i) : 1

        # TODO: choice children: | any
        choice.elements      = node.children_objs Element
        choice.groups        = node.children_objs Group
        choice.choices       = node.children_objs Choice
        choice.sequences     = node.children_objs Sequence

        choice
      end

      # resolve hanging references given complete xsd node object array
      def resolve(node_objs); end

      # convert choice to array of class builders
      def to_class_builders
        # FIXME: enforce "only one attribute must be set"

        unless defined? @class_builders
          @class_builders = []
          @elements.each do |e|
            @class_builders.push e.to_class_builder
          end
          @groups.each do |g|
            g.to_class_builders.each do |gcb|
              @class_builders.push gcb
            end
          end
          @choices.each do |c|
            c.to_class_builders.each do |ccb|
              @class_builders.push ccb
            end
          end
          @sequences.each do |s|
            s.to_class_builders.each do |scb|
              @class_builders.push scb
            end
          end
        end

        @class_builders
      end

      # return all child attributes assocaited w/ choice
      def child_attributes
        atts = []
        @elements&.each do |elem|
          eca = elem.child_attributes
          atts += eca unless eca.nil?
        end
        @sequences&.each { |seq| atts += seq.child_attributes }
        @choices&.each   { |ch| atts += ch.child_attributes }
        @groups&.each    { |gr| atts += gr.child_attributes }
        atts
      end
      end
    end # module XSD
end # module RXSD
