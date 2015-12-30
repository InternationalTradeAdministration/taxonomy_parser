require 'iso_country_codes'

module LookupMethods

  def get_all_geo_terms_for_country(country_code)
    country_name = IsoCountryCodes.find(country_code).name
    country_term = find_concept_by_label(country_name)
    broader_terms = []
    process_broader_terms(country_term) do |broader_term|
      broader_terms.push broader_term
    end

    world_region_terms = find_concepts_by_concept_group("World Regions", broader_terms)
    trade_region_terms = find_concepts_by_concept_group("Trade Regions", broader_terms)

    return world_region_terms + trade_region_terms
  end

  def find_concepts_by_concept_group(concept_group, terms = concepts)
    terms.select{ |term| term[:concept_groups].include? concept_group }
  end

  def find_concept_by_label(label)
    concepts.find{ |concept| concept[:label] == label }
  end

  private

  def process_broader_terms(term, &block)
    term[:broader_terms].each do |broader_label|
      broader_term = find_concept_by_label(broader_label)
      yield broader_term if broader_term
      process_broader_terms(broader_term, &block) if broader_term
    end
  end
end