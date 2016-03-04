require 'iso_country_codes'
require 'yaml'

module LookupMethods

  def get_all_geo_terms_for_country(country)
    country_name = extract_country_name(country)
    country_name = normalize_country(country_name)

    country_term = extract_country_term(country_name)

    broader_terms = []
    process_broader_terms(country_term) do |broader_term|
      broader_terms.push broader_term
    end
    broader_terms.uniq!

    world_region_terms = get_concepts_by_concept_group("World Regions", broader_terms)
    trade_region_terms = get_concepts_by_concept_group("Trade Regions", broader_terms)
    related_term_labels = extract_object_property_labels(country_term, :has_related)
    related_terms = related_term_labels.map{|label| get_concept_by_label(label) }

    trade_region_terms.concat(get_concepts_by_concept_group("Trade Regions", related_terms))

    return world_region_terms + trade_region_terms
  end

  def get_parents_for_geo_term(geo_term)

  end

  def get_concepts_by_concept_group(concept_group, terms = concepts)
    terms.select{ |term| extract_object_property_labels(term, :member_of).include?(concept_group) }
  end

  def get_concept_by_label(label)
    sf_mappings = YAML.load_file(File.dirname(__FILE__) + "/../salesforce_label_mappings.yaml")
    label = sf_mappings[label] if sf_mappings.has_key?(label)
    concepts.find{ |concept| concept[:label] == label }
  end

  def extract_country_term(country_name)
    country_term = get_concept_by_label(country_name)
    country_term = partial_match_by_label(country_name) if country_term.nil?
    fail "Country term can't be found for: #{country_name}" if country_term.nil?
    country_term
  end

  private

  def extract_object_property_labels(term, key)
    term[:object_properties][key].map{|hash| hash[:label]} rescue []
  end

  def find_by_id(id, terms = nil)
    terms = @concepts + @concept_groups + @concept_schemes if terms.nil?
    terms.find{ |term| term[:subject] == id }
  end

  def process_broader_terms(term, &block)
    broader_labels = extract_object_property_labels(term, :has_broader)
    broader_labels.each do |broader_label|
      broader_term = get_concept_by_label(broader_label)
      yield broader_term if broader_term
      process_broader_terms(broader_term, &block) if broader_term
    end
  end

  def partial_match_by_label(label)
    concepts.find{ |concept| concept[:label].include?(label) || label.include?(concept[:label]) }
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