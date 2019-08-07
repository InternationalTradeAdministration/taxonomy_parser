module OwlClassTypeDetector
  extend OwlXpathHelper

  WHITELISTED_GEOGRAPHIC_LOCATIONS_TYPES = [
    'Countries',
    'Trade Regions',
    'U.S. States and Territories',
    'World Regions'
  ]

  WHITELISTED_TYPES = [
    'Industries',
    'Trade Topics',
    'U.S. Government'
  ].freeze

  US_STATES_TERRITORIES_CONCEPT_GROUP_IRI = 'http://webprotege.stanford.edu/Rqdpj5QSp8PxZGtrXuOpdK'.freeze

  def detect(node, parent_class)
    if WHITELISTED_TYPES.include? parent_class[:label]
      return [parent_class[:label]]
    elsif WHITELISTED_GEOGRAPHIC_LOCATIONS_TYPES.include? parent_class[:label]
      return ['Geographic Locations', parent_class[:label]]
    end

    if us_states_and_territories? node
      ['Geographic Locations', 'U.S. States and Territories']
    else
      parent_class[:type] || []
    end
  end

  def us_states_and_territories?(node)
    current_node_main_concept_of? node, US_STATES_TERRITORIES_CONCEPT_GROUP_IRI
  end

  extend self
end
