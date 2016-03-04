module PropertyExtractor

  private

  def extract_properties(node)
    datatype_properties = {}
    object_properties = {}
    all_fields = extract_leaf_nodes(node)

    property_nodes = node.xpath("./subClassOf/Restriction")

    property_nodes.each do |property_node|
      process_property_node(property_node, datatype_properties, object_properties)
    end

    combined_properties = {datatype_properties: datatype_properties, object_properties: object_properties}
    all_fields.merge(combined_properties)
  end

  def extract_leaf_nodes(node)
    leaf_nodes = node.xpath("./*[not(child::*)]")
    leaf_properties = leaf_nodes.map{|node| { node.name.gsub(' ', '_').to_sym => node.text} }.reduce Hash.new, :merge
    leaf_properties[:subClassOf] = extract_parent_ids(leaf_nodes)
    leaf_properties
  end

  def extract_parent_ids(leaf_nodes)
    parent_nodes = leaf_nodes.select{|node| node.name == 'subClassOf'}
    parent_nodes.map do |node|
      {id: node.attr('resource')}
    end
  end

  def process_property_node(property_node, datatype_properties, object_properties)
    property_iri = property_node.xpath('./onProperty').first.attr('resource')

    object_source_node = @xml.xpath("//ObjectProperty[@about='#{property_iri}']").first
    extract_object_property(property_node, object_source_node, object_properties) unless object_source_node.nil?

    datatype_source_node = @xml.xpath("//DatatypeProperty[@about='#{property_iri}']").first if object_source_node.nil?

    if datatype_source_node.nil? && object_source_node.nil?
      fail "Not an Object or Data property: #{property_iri}"
    elsif !datatype_source_node.nil?
      extract_datatype_property(property_node, datatype_source_node, datatype_properties)
    end
  end

  def extract_datatype_property(property_node, datatype_source_node, datatype_properties)
    target_value = property_node.xpath('./hasValue').text
    property_key = extract_label(datatype_source_node).gsub(' ', '_').to_sym
    add_property(datatype_properties, property_key, target_value)
  end

  def extract_object_property(property_node, object_source_node, object_properties)
    target_id = property_node.xpath('./someValuesFrom').first.attr('resource') rescue property_node.xpath('./hasValue').first.attr('resource')
    property_key = extract_label(object_source_node).gsub(' ', '_').to_sym
    add_property(object_properties, property_key, {id: target_id})
  end

  def add_property(hash, key, value)
    hash[key] = [] unless hash.has_key?(key)
    hash[key] << value
  end
end