require 'spec_helper'
require 'yaml'
require 'nokogiri'

describe PropertyExtractor do
  before(:all) do
    data_dir = File.dirname(__FILE__) + "/fixtures/test_data.zip"
    parser = TaxonomyParser.new(data_dir)

    @xml = Nokogiri::XML(parser.raw_source)
    @xml.remove_namespaces!

    @expected_properties = YAML.load_file(File.dirname(__FILE__) + "/fixtures/properties.yaml")
  end

  context 'when the node is a concept containing annotations and datatype and object properties' do
    it 'extracts the correct properties for a node' do
      node = @xml.xpath("//Class[@about='http://webprotege.stanford.edu/RDzjXT0GYF9ecQbq6oyxewD']").first

      actual_properties = PropertyExtractor.extract_properties(node, @xml)

      expect(actual_properties).to eq(@expected_properties[0])
    end
  end

  context 'when the node is a concept group containing annotations, but no datatype or object properties' do
    it 'extracts the correct properties for a node' do
      node = @xml.xpath("//Class[@about='http://webprotege.stanford.edu/R8W91u35GBegWcXXFflYE4']").first

      actual_properties = PropertyExtractor.extract_properties(node, @xml)

      expect(actual_properties).to eq(@expected_properties[1])
    end
  end
end