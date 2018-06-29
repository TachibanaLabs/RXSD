# frozen_string_literal: true

# tests the translator module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require File.dirname(__FILE__) + '/spec_helper'

describe 'Translator' do
  # FIXME: test child_attributes on all XSD classes!

  before(:each) do
    @data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' \
            '<xs:simpleType name="MyStrType">' \
            '  <xs:restriction base="xs:string" />' \
            '</xs:simpleType>' \
            '<xs:simpleType name="MyFArrType">' \
            '  <xs:list itemType="xs:float" />' \
            '</xs:simpleType>' \
            '<xs:complexType id="ct1" name="MyType">' \
            '<xs:complexContent id="cc1">' \
            '<xs:extension id="e1" base="xs:string">' \
            '<xs:attribute name="my_s" type="xs:string"/>' \
            '<xs:attribute name="my_a" type="MyFArrType" />' \
            '</xs:extension>' \
            '</xs:complexContent>' \
            '</xs:complexType>' \
            '<xs:element name="Kaboom" type="MyStrType"/>' \
            '<xs:element name="Foomanchu" type="xs:boolean"/>' \
            '<xs:element name="MoMoney" type="MyType"/>' \
            '</schema>'
  end

  it 'should generate correct schema tags' do
    schema = Parser.parse_xsd raw: @data
    tags = schema.tags
    tags.size.should == 5
    tags.key?('Kaboom').should == true
    tags.key?('Foomanchu').should == true
    tags.key?('MoMoney').should == true
    tags.key?('MoMoney:my_s').should == true
    tags.key?('MoMoney:my_a').should == true
    tags['Kaboom'].should_not be_nil
  end

  # def test_schema_all_builders
  # end

  it 'should generate ruby classes' do
    schema = Parser.parse_xsd raw: @data
    classes = schema.to :ruby_classes
    classes.size.should == 6
    classes.include?(XSDFloat).should == true
    classes.include?(Array).should == true
    classes.include?(String).should == true
    classes.include?(Boolean).should == true
    classes.include?(Kaboom).should == true
    classes.include?(MoMoney).should == true
    momoney = MoMoney.new
    momoney.method(:my_s).should_not be_nil
    momoney.method(:my_s=).should_not be_nil
    momoney.method(:my_a).should_not be_nil
    momoney.method(:my_a=).should_not be_nil
  end

  it 'should generate ruby class definitions' do
    schema = Parser.parse_xsd raw: @data
    classes = schema.to :ruby_definitions
    classes.size.should == 6
    classes.include?("class XSDFloat\nend").should == true
    classes.include?("class Array\nend").should == true
    classes.include?("class String\nend").should == true
    classes.include?("class Boolean\nend").should == true
    classes.include?("class Kaboom < String\nend").should == true
    classes.include?("class MoMoney < String\n" \
                       "attr_accessor :my_s\n" \
                       "attr_accessor :my_a\n" \
                     'end').should == true
  end

  it 'should generate ruby objects' do
    schema = Parser.parse_xsd raw: @data
    classes = schema.to :ruby_classes

    instance = '<Kaboom>yo</Kaboom>'
    schema_instance = Parser.parse_xml raw: instance
    objs = schema_instance.to :ruby_objects, schema: schema
    objs.size.should == 1
    objs.collect(&:class).include?(Kaboom).should == true
    objs.find { |o| o.class == Kaboom }.should == 'yo'

    instance = '<Foomanchu>true</Foomanchu>'
    schema_instance = Parser.parse_xml raw: instance
    objs = schema_instance.to :ruby_objects, schema: schema
    objs.size.should == 1
    objs[0].should == true

    instance = '<MoMoney my_s="abc" />'
    schema_instance = Parser.parse_xml raw: instance
    objs = schema_instance.to :ruby_objects, schema: schema
    objs.size.should == 1
    objs.collect(&:class).include?(MoMoney).should == true
    objs.find { |o| o.class == MoMoney }.my_s.should == 'abc'
  end
end
