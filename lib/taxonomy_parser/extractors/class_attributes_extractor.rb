class ClassAttributesExtractor
  include OwlXpathHelper

  EXCLUDED_ANNOTATION_ATTRIBUTES = %i(label sub_class_of)

  def initialize(xml)
    @xml = xml
    @property_types = {}
  end

  def extract_attributes(node)
    object_properties = extract_object_properties(node)

    {
      id: extract_id_from_node(node),
      label: extract_label(node),
      annotations: extract_annotations(node),
      object_properties: object_properties
    }
  end

  private

  def extract_object_properties(node)
    xpath(node, './rdfs:subClassOf/owl:Restriction[owl:someValuesFrom]').each_with_object({}) do |restriction, coll|
      property = extract_object_property restriction
      coll[property[:type]] ||= []
      coll[property[:type]].push property.slice(:id)
    end
  end

  def extract_annotations(node)
    extract_nodes_without_child(node).select do |key, _value|
      !EXCLUDED_ANNOTATION_ATTRIBUTES.include?(key)
    end
  end

  def extract_nodes_without_child(node)
    node.xpath('./*[not(child::*)]').each_with_object({}) do |element, hash|
      key = normalize_attribute_name element.name
      hash[key] ||= []
      hash[key].push(element.text.squish) unless EXCLUDED_ANNOTATION_ATTRIBUTES.include?(key)
    end
  end

  def extract_object_property(restriction)
    property_iri = xpath(restriction, './owl:someValuesFrom').first['rdf:resource']
    {
      type: property_type(restriction),
      id: extract_id(property_iri),
    }
  end

  def property_type(restriction)
    property_type_iri = xpath(restriction, './owl:onProperty').first['rdf:resource']
    @property_types[property_type_iri] ||= extract_property_type(property_type_iri)
  end

  def extract_property_type(property_type_iri)
    property_type_label = xpath_text_content @xml, "//owl:ObjectProperty[@rdf:about='#{property_type_iri}']/rdfs:label"
    normalize_attribute_name property_type_label
  end

  def normalize_attribute_name(name)
    name.demodulize.underscore.gsub(/ /, '_').to_sym
  end
end
