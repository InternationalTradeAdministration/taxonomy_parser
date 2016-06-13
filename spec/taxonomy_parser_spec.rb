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

  context 'when the parser is initialized with an array of OWL files' do
    files = [File.dirname(__FILE__) + "/fixtures/test_data/extra-xml.owl", File.dirname(__FILE__) + "/fixtures/test_data/root-ontology.owl"]
    @parser = TaxonomyParser.new(files)
    @parser.parse

    it 'returns the correct full terms from XML source' do
      expect(@parser.terms.size).to eq(@expected_full_terms.size)
      expect(@parser.terms).to match_array(@expected_full_terms)
    end

    it 'returns the correct raw_source' do
      expected_raw_source = File.open(File.dirname(__FILE__) + "/fixtures/raw_source.xml", :encoding => 'ascii-8bit').read
      expect(@parser.raw_source).to eq(expected_raw_source)
    end
  end
end
