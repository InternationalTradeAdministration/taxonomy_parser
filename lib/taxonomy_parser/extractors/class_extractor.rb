module Extractors
  class ClassExtractor
    CONCEPT_SCHEME_LABEL = 'Thesaurus of International Trade and Investment Terms'

    def initialize(xml)
      @xml = xml
      @attributes_extractor = ClassAttributesExtractor.new @xml
    end

    def extract
      owl_classes_hash = {}

      OwlXpathHelper.top_level_concept_group_nodes(@xml).each do |cg_node|
        extract_owl_class owl_classes_hash, cg_node, {}
      end

      concept_scheme = extract_concept_scheme
      owl_classes_hash[concept_scheme[:id]] = concept_scheme

      assign_object_properties_label owl_classes_hash
    end

    private

    def extract_owl_class(hash, node, parent)
      node_iri = OwlXpathHelper.extract_id_from_node node
      return if hash[node_iri]

      owl_class = @attributes_extractor.extract_attributes node
      owl_class[:type] = OwlClassTypeDetector.detect node,
                                                     parent

      hash[node_iri] = owl_class

      OwlXpathHelper.sub_group_nodes(@xml, node).each do |sub_node|
        extract_owl_class hash,
                          sub_node,
                          owl_class
      end

      OwlXpathHelper.main_concept_in_collection_nodes(@xml, node).each do |sub_node|
        extract_owl_class hash,
                          sub_node,
                          owl_class
      end

      OwlXpathHelper.sub_class_nodes(@xml, node).each do |sub_node|
        extract_owl_class hash,
                          sub_node,
                          owl_class
      end
    end

    def extract_concept_scheme
      concept_scheme_node = OwlXpathHelper.owl_class_nodes_by_label(@xml, CONCEPT_SCHEME_LABEL).first
      @attributes_extractor.extract_attributes(concept_scheme_node).merge(type: [])
    end

    def assign_object_properties_label(owl_classes_hash)
      owl_classes_hash.each do |_id, owl_class|
        owl_class[:object_properties].each do |_property_type, properties|
          properties.each do |property|
            property_class = owl_classes_hash[property[:id]]
            property[:label] = property_class ? property_class[:label] : 'missing term'
          end
        end
      end
    end
  end
end
