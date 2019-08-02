module OwlXpathHelper
  NAMESPACE_HASH = {
    owl: 'http://www.w3.org/2002/07/owl#',
    rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    rdfs: 'http://www.w3.org/2000/01/rdf-schema#' }.freeze

  CONCEPT_GROUP_IRI = 'http://purl.org/iso25964/skos-thes#ConceptGroup'.freeze

  SUB_GROUP_PATH_TEMPLATE = <<-template
//owl:Class
  [rdfs:subClassOf
    [owl:Restriction
      [owl:onProperty[@rdf:resource='http://purl.org/iso25964/skos-thes#superGroup']]
      [owl:someValuesFrom[@rdf:resource='%s']]
    ]
  ]
  template

  CLASS_MAIN_CONCEPT_OF_TEMPLATE = <<-template
//owl:Class
  [rdfs:subClassOf
    [owl:Restriction
      [owl:onProperty[@rdf:resource='http://purl.org/umu/uneskos#mainConceptOf']]
      [owl:someValuesFrom[@rdf:resource='%s']]
    ]
  ]
  template

  SUB_CLASS_PATH_TEMPLATE = <<-template
//owl:Class
  [rdfs:subClassOf
    [owl:Restriction
      [owl:onProperty[@rdf:resource='http://www.w3.org/2004/02/skos/core#broader']]
      [owl:someValuesFrom[@rdf:resource='%s']]
    ]
  ]
  template

  CURRENT_NODE_MAIN_CONCEPT_TEMPLATE = <<-template
./rdfs:subClassOf
    [owl:Restriction
      [owl:onProperty[@rdf:resource='http://purl.org/umu/uneskos#mainConceptOf']]
      [owl:someValuesFrom[@rdf:resource='%s']]
    ]
  template

  def top_level_concept_group_nodes(xml)
    xpath xml, "//owl:Class[rdfs:subClassOf[@rdf:resource='#{CONCEPT_GROUP_IRI}']]"
  end

  def sub_group_nodes(xml, node)
    # super_group_iri = node['rdf:about']
    # xpath xml, (SUB_GROUP_PATH_TEMPLATE % super_group_iri)
    filtered_nodes xml, node, SUB_GROUP_PATH_TEMPLATE
  end

  def main_concept_in_collection_nodes(xml, node)
    filtered_nodes xml, node, CLASS_MAIN_CONCEPT_OF_TEMPLATE
  end

  def sub_class_nodes(xml, node)
    filtered_nodes xml, node, SUB_CLASS_PATH_TEMPLATE
  end

  def filtered_nodes(xml, node, path)
    node_iri = node['rdf:about']
    xpath xml, (path % node_iri)
  end

  def current_node_main_concept_of?(node, class_iri)
    xpath(node, (CURRENT_NODE_MAIN_CONCEPT_TEMPLATE % class_iri)).present?
  end

  def owl_class_nodes_by_label(xml, label)
    xpath(xml, "//owl:Class[rdfs:label[text()='#{label}']]")
  end

  def xpath(xml, path)
    xml.xpath path, NAMESPACE_HASH
  end

  def xpath_text_content(xml, path)
    text = xml.xpath "#{path}/text()", NAMESPACE_HASH
    text.first.content.squish if text.present?
  end

  def extract_label(node)
    xpath_text_content node, './rdfs:label'
  end

  def extract_id_from_node(node)
    node['rdf:about'].sub(%r[^http://webprotege.stanford.edu/], '').strip
  end

  def extract_id(iri)
    iri.sub(%r[^http://webprotege.stanford.edu/], '').strip
  end

  extend self
end
