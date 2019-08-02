module Extractors
  class ClassExtractor
    WHITELISTED_TYPES = [
      'Countries',
      'Industries',
      'Trade Regions',
      'Trade Topics',
      'U.S. States and Territories',
      'U.S. Government',
      'World Regions'
    ].freeze

    CONCEPT_SCHEME_LABEL = 'Thesaurus of International Trade and Investment Terms'

    def initialize(xml)
      @xml = xml
      @attributes_extractor = ClassAttributesExtractor.new @xml
    end

    def extract
      owl_classes = OwlXpathHelper.top_level_concept_group_nodes(@xml).each_with_object({}) do |cg_node, hash|
        extract_owl_class hash, cg_node
      end

      concept_scheme = extract_concept_scheme
      owl_classes[concept_scheme[:id]] = concept_scheme

      assign_object_properties_label owl_classes
    end

    private

    def extract_owl_class(hash, node, parent_label:nil, parent_types:[])
      node_iri = OwlXpathHelper.extract_id_from_node node
      return if hash[node_iri]

      owl_class = @attributes_extractor.extract_attributes node
      owl_class[:type] = OwlClassTypeDetector.detect node,
                                                     parent_label,
                                                     parent_types

      hash[node_iri] = owl_class

      OwlXpathHelper.sub_group_nodes(@xml, node).each do |sub_group_node|
        extract_owl_class hash,
                          sub_group_node,
                          parent_label: owl_class[:label],
                          parent_types: owl_class[:type]
      end

      OwlXpathHelper.main_concept_in_collection_nodes(@xml, node).each do |sub_group_node|
        extract_owl_class hash,
                          sub_group_node,
                          parent_label: owl_class[:label],
                          parent_types: owl_class[:type]
      end

      OwlXpathHelper.sub_class_nodes(@xml, node).each do |sub_group_node|
        extract_owl_class hash,
                          sub_group_node,
                          parent_label: owl_class[:label],
                          parent_types: owl_class[:type]
      end
    end

    def extract_concept_scheme
      concept_scheme_node = OwlXpathHelper.owl_class_nodes_by_label(@xml, CONCEPT_SCHEME_LABEL).first
      @attributes_extractor.extract_attributes(concept_scheme_node).merge(type: [])
    end

    def assign_object_properties_label(owl_classes)
      owl_classes.each do |_id, owl_class|
        owl_class[:object_properties].each do |_property_type, properties|
          properties.each do |property|
            property_class = owl_classes[property[:id]]
            property[:label] = property_class ? property_class[:label] : 'missing term'
          end
        end
      end
    end
  end
end
