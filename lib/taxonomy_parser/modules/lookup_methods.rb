require 'iso_country_codes'
require 'yaml'

module LookupMethods

  HIGH_LEVEL_TYPES = ['Countries', 'Industries', 'Trade Topics', 'Trade Regions', 'World Regions']

  def get_all_geo_terms_for_country(country)
    country_name = extract_country_name(country)
    country_name = normalize_country(country_name)

    country_term = extract_country_term(country_name)

    broader_terms = extract_broader(country_term)
    related_terms = extract_related(country_term)

    world_region_terms = get_concepts_by_concept_group("World Regions", broader_terms)
    trade_region_terms = get_concepts_by_concept_group("Trade Regions", broader_terms + related_terms)

    world_region_terms + trade_region_terms
  end

  def get_concepts_by_concept_group(concept_group, passed_terms = terms)
    passed_terms.select{ |term| extract_object_property_labels(term, :member_of).include?(concept_group) }
  end

  def get_term_by_label(label)
    sf_mappings = YAML.load_file(File.dirname(__FILE__) + "/../salesforce_label_mappings.yaml")
    label = sf_mappings[label] if sf_mappings.has_key?(label)
    terms.find{ |term| term[:label] == label }
  end

  def extract_country_term(country_name)
    country_term = get_term_by_label(country_name)
    country_term = partial_match_by_label(country_name) if country_term.nil?
    fail "Country term can't be found for: #{country_name}" if country_term.nil?
    country_term
  end

  def get_high_level_type(label)
    term = get_term_by_label(label)
    high_level_types = process_subclass_of(term[:subject])
    high_level_types.select { |type| HIGH_LEVEL_TYPES.include?(type)}
  end

  def find_by_id(id, passed_terms = nil)
    passed_terms = terms if passed_terms.nil?
    passed_terms.find{ |term| term[:subject] == id }
  end

  private

  def process_subclass_of(id)
    parent = find_by_id(id)
    member_of_labels = extract_object_property_labels(parent, :member_of)
    # If term is not a member of a high level type and is not a top-level term, process its parent:
    if (member_of_labels & HIGH_LEVEL_TYPES).empty? && !parent[:sub_class_of].empty?
      return process_subclass_of(parent[:sub_class_of].first[:id])
    else
      return member_of_labels
    end
  end

  def extract_object_property_labels(term, key)
    term[:object_properties][key].map{|hash| hash[:label]} rescue []
  end

  def extract_related(term)
    related_term_labels = extract_object_property_labels(term, :has_related)
    related_term_labels.map{|label| get_term_by_label(label) }
  end

  def extract_broader(term)
    broader_terms = []
    process_tree_property(term, :has_broader) do |broader_term|
      broader_terms.push broader_term
    end
    broader_terms.uniq
  end

  def process_tree_property(term, property_key, &block)
    labels = extract_object_property_labels(term, property_key)
    labels.each do |label|
      term = get_term_by_label(label)
      yield term if term
      process_tree_property(term, property_key, &block) if term
    end
  end

  def partial_match_by_label(label)
    terms.find{ |term| term[:label].include?(label) || label.include?(term[:label]) }
  end

  def extract_country_name(country)
    country =~ /\A[A-Z]{2}\z/ ? IsoCountryCodes.find(country).name : country
  end

  def normalize_country(country_str)
    country_name_mappings = YAML.load_file(File.dirname(__FILE__) + "/../country_mappings.yaml")

    mapping = country_name_mappings.select do |_key, array|
      array.include? country_str
    end

    mapping.empty? ? country_str : mapping.keys.first
  end
end
