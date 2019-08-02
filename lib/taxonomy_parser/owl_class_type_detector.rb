module OwlClassTypeDetector
  extend OwlXpathHelper

  WHITELISTED_TYPES = [
    'Countries',
    'Industries',
    'Trade Regions',
    'Trade Topics',
    'U.S. States and Territories',
    'U.S. Government',
    'World Regions'
  ].freeze

  US_STATES_TERRITORIES_CONCEPT_GROUP_IRI = 'http://webprotege.stanford.edu/Rqdpj5QSp8PxZGtrXuOpdK'.freeze

  def detect(node, parent_label, parent_types)
    return [parent_label] if WHITELISTED_TYPES.include? parent_label

    if us_states_and_territories? node
      ['U.S. States and Territories']
    else
      parent_types
    end
  end

  def us_states_and_territories?(node)
    current_node_main_concept_of? node, US_STATES_TERRITORIES_CONCEPT_GROUP_IRI
  end

  extend self
end
