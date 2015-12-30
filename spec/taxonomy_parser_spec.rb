require 'spec_helper'
require 'yaml'

describe TaxonomyParser do
  before do
    data_dir = File.dirname(__FILE__) + "/fixtures/test_data.zip"
    @parser = TaxonomyParser.new(data_dir)
    @parser.parse
    @expected_concepts = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concepts.yaml")
    @expected_concept_groups = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concept_groups.yaml")
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

  context 'LookupMethods module' do
    describe '#get_all_geo_terms_for_country' do
      it 'returns the correct geo_terms for a country' do
        expected_geo_terms = @expected_concepts.select{|concept| ["World Regions", "Trade Regions"].include? concept[:concept_groups].first }
        expect(@parser.get_all_geo_terms_for_country('AF')).to match_array(expected_geo_terms)
      end
    end

    describe '#find_concepts_by_concept_group' do
      it 'returns all concepts that are member of a concept group' do
        expected_concepts_for_countries = @expected_concepts.select{|concept| concept[:concept_groups].include? "Countries" }
        expect(@parser.find_concepts_by_concept_group('Countries')).to match_array(expected_concepts_for_countries)
      end
    end

    describe '#find_concept_by_label' do
      it 'returns the correct concept for a given label' do
        expected_concept_for_label = @expected_concepts.find{|concept| concept[:label] == "Aviation" }
        expect(@parser.find_concept_by_label("Aviation")).to eq expected_concept_for_label
      end
    end

  end
end
