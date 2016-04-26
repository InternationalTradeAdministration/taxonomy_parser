require 'spec_helper'
require 'yaml'

describe PostProcessor do
  before(:all) do
    @data_dir = File.dirname(__FILE__) + "/fixtures/test_data.zip"
    @unprocessed_terms = YAML.load_file(File.dirname(__FILE__) + "/fixtures/unprocessed_terms.yaml")
    @parser = TaxonomyParser.new(@data_dir, @unprocessed_terms)

    expected_concepts = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concepts.yaml")
    expected_concept_groups = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concept_groups.yaml")
    expected_concept_schemes = YAML.load_file(File.dirname(__FILE__) + "/fixtures/concept_schemes.yaml")
    @expected_terms = expected_concepts + expected_concept_groups + expected_concept_schemes
  end

  it 'assigns the correct labels to properties and deletes top-level parents' do
    actual_terms = PostProcessor.process_terms(@parser)

    expect(actual_terms).to eq(@expected_terms)
  end
end