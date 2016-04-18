require 'spec_helper'
require 'yaml'

describe TaxonomyParser do
  before(:all) do
    @data_dir = File.dirname(__FILE__) + "/fixtures/test_data.zip"
    @parser = TaxonomyParser.new(@data_dir)
    @parser.parse

    @expected_concepts = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concepts.yaml")
    @expected_concept_groups = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concept_groups.yaml")
    @expected_concept_schemes = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concept_schemes.yaml")
    @expected_full_terms = @expected_concepts + @expected_concept_groups + @expected_concept_schemes
  end

  it 'has a version number' do
    expect(TaxonomyParser::VERSION).not_to be nil
  end

  it 'parses the correct concept groups' do
    expect(@parser.concept_groups.size).to eq(@expected_concept_groups.size)
    expect(@parser.concept_groups).to match_array(@expected_concept_groups)
  end

  it 'parses the correct concepts' do
    expect(@parser.concepts.size).to eq(@expected_concepts.size)
    expect(@parser.concepts).to match_array(@expected_concepts)
  end

  it 'parses the correct concept schemes' do
    expect(@parser.concept_schemes.size).to eq(@expected_concept_schemes.size)
    expect(@parser.concept_schemes).to match_array(@expected_concept_schemes)
  end

  it 'returns the correct full terms from XML source' do
    expect(@parser.terms.size).to eq(@expected_full_terms.size)
    expect(@parser.terms).to match_array(@expected_full_terms)
  end

  it 'returns the correct full terms when pre-loaded with data' do
    parser = TaxonomyParser.new(@data_dir, @expected_full_terms)
    expect(@parser.terms.size).to eq(@expected_full_terms.size)
    expect(@parser.terms).to match_array(@expected_full_terms)
  end

  it 'returns the correct raw_source' do
    expected_raw_source = File.open(File.dirname(__FILE__) + "/fixtures/raw_source.xml", :encoding => 'ascii-8bit').read
    expect(@parser.raw_source).to eq(expected_raw_source)
  end

  context 'LookupMethods module' do
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
end
