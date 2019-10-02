require 'spec_helper'
require 'yaml'

describe LookupMethods do
  before(:all) do
    @data_file = File.dirname(__FILE__) + "/fixtures/test_data/root-ontology.owl"
    @parser = TaxonomyParser.new([@data_file])
    @parser.parse

    @expected_concepts = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concepts.yaml")
    @expected_concept_groups = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concept_groups.yaml")
    @expected_concept_schemes = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concept_schemes.yaml")
    @expected_full_terms = @expected_concepts + @expected_concept_groups + @expected_concept_schemes
  end

  describe '#get_high_level_type' do
    it 'returns the correct top level type for a given term' do
      expect(@parser.get_high_level_type('Afghanistan')).to eq(["Countries"])
      expect(@parser.get_high_level_type('Aviation')).to eq(["Industries"])
      expect(@parser.get_high_level_type('Regional Organizations')).to eq(["Trade Topics"])
      expect(@parser.get_high_level_type('Economic Cooperation Organization')).to eq(["Trade Regions"])
      expect(@parser.get_high_level_type('Central Asia')).to eq(["World Regions"])
    end
  end

  describe '#get_all_geo_terms_for_country' do
    it 'returns the correct geo_terms for a country code or name' do
      expected_geo_terms = @expected_concepts.select{|concept| ["World Regions", "Trade Regions"].include? concept[:object_properties][:member_of].first[:label] rescue nil}
      expect(@parser.get_all_geo_terms_for_country('AF')).to match_array(expected_geo_terms)
      expect(@parser.get_all_geo_terms_for_country('Afghanistan')).to match_array(expected_geo_terms)
    end
  end

  describe '#extract_country_term' do
    it 'returns term for partial match' do
      us_term = @expected_concepts.find{|concept| concept[:label] == "United States"}
      expect(@parser.extract_country_term("United States of America")).to eq(us_term)
    end

    it 'raises an error when the country term cannot be found from the given name' do
      expect{@parser.get_all_geo_terms_for_country('United Kingdom')}.to raise_error("Country term can't be found for: United Kingdom")
    end
  end

  describe '#get_concepts_by_concept_group' do
    it 'returns all concepts that are member of a concept group' do
      expected_concepts_for_countries = @expected_concepts.select{|concept| concept[:object_properties][:member_of].map{|p| p[:label]}.include? "Countries" rescue nil}
      expect(@parser.get_concepts_by_concept_group('Countries')).to match_array(expected_concepts_for_countries)
    end
  end

  describe '#get_term_by_label' do
    it 'returns the correct term for a given label' do
      expected_concept_for_label = @expected_concepts.find{|concept| concept[:label] == "Aviation" }
      expect(@parser.get_term_by_label("Aviation")).to eq expected_concept_for_label
    end

    it 'returns the correct term for a label that requires a mapping lookup' do
      expected_concept_for_label = @expected_concepts.find{|concept| concept[:label] == "Aviation" }
      expect(@parser.get_term_by_label("Avi ation")).to eq expected_concept_for_label
    end
  end

end
