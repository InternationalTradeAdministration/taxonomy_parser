require 'iso_country_codes'

module LookupMethods

  def get_all_geo_terms_for_country(country)
    country_name = extract_country_name(country)
    country_term = extract_country_term(country_name)

    broader_terms = []
    process_broader_terms(country_term) do |broader_term|
      broader_terms.push broader_term
    end

    world_region_terms = get_concepts_by_concept_group("World Regions", broader_terms)
    trade_region_terms = get_concepts_by_concept_group("Trade Regions", broader_terms)

    return world_region_terms + trade_region_terms
  end

  def get_concepts_by_concept_group(concept_group, terms = concepts)
    terms.select{ |term| term[:concept_groups].include? concept_group }
  end

  def get_concept_by_label(label)
    concepts.find{ |concept| concept[:label] == label }
  end

  def extract_country_term(country_name)
    country_term = get_concept_by_label(country_name)
    country_term = partial_match_by_label(country_name) if country_term.nil?
    fail "Country term can't be found." if country_term.nil?
    country_term
  end

  private

  def process_broader_terms(term, &block)
    term[:broader_terms].each do |broader_label|
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
end