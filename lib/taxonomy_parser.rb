require 'taxonomy_parser/version'
require 'taxonomy_parser/lookup_methods'
require 'nokogiri'
require 'open-uri'
require 'zip'

class TaxonomyParser
  include LookupMethods
  PROTEGE_URL = 'http://52.4.82.207:8080/webprotege/download?ontology=cafcdef1-058a-41dd-9c6e-19a0bc297c86'
  CONCEPT_GROUP_IRI = 'http://purl.org/iso25964/skos-thes#ConceptGroup'
  CONCEPT_IRI = 'http://www.w3.org/2004/02/skos/core#Concept'

  MEMBER_OF_IRI = 'http://purl.org/umu/uneskos#memberOf'
  BROADER_IRI = 'http://www.w3.org/2004/02/skos/core#broader'

  def initialize(resource = PROTEGE_URL)
    @resource = resource
    @concepts = []
    @concept_groups = []
    @xml = extract_xml_from_zip
  end

  def parse
    extract_terms(@concept_groups, CONCEPT_GROUP_IRI)
    extract_terms(@concepts, CONCEPT_IRI)
  end

  def concept_groups
    @concept_groups
  end

  def concepts
    @concepts
  end

  private

  def extract_terms(terms, iri)
    root_node = @xml.xpath("//rdf:Description[@rdf:about='#{iri}']").first
    root_node_hash = extract_node_hash(root_node)
    process_subclass_nodes(root_node_hash) do |node_hash|
      terms.push node_hash
    end
  end

  def process_subclass_nodes(node_hash, &block)
    node_hash[:subclass_nodes].each do |child_node|
      child_node_hash = extract_node_hash(child_node, node_hash[:path])
      next if child_node_hash[:subject] == node_hash[:subject] # Handle case where class is parent of itself... gotta love Protege!
      yield child_node_hash.reject{ |k| k == :subclass_nodes }
      process_subclass_nodes(child_node_hash, &block)
    end
  end

  def extract_node_hash(node, parent_path = nil)
    label = extract_label(node)
    path = build_path(parent_path, label)
    subject = extract_subject(node)
    concept_groups = extract_additional_property(node, MEMBER_OF_IRI)
    broader_terms = extract_additional_property(node, BROADER_IRI)
    subclass_nodes = extract_subclass_nodes(subject)
    { 
      label: label,
      leaf_node: subclass_nodes.empty?,
      path: path,
      subclass_nodes: subclass_nodes,
      subject: subject,
      concept_groups: concept_groups,
      broader_terms: broader_terms
    }
  end

  def extract_additional_property(node, iri)
    internal_nodes = node.xpath("./rdfs:subClassOf/owl:Restriction[owl:onProperty[@rdf:resource='#{iri}']]")
    related_subjects = internal_nodes.map{ |node| node.xpath('./owl:someValuesFrom').first.attr('rdf:resource')}.flatten
    related_nodes = related_subjects.map{ |subject| @xml.xpath("//owl:Class[@rdf:about='#{subject}']")}.flatten
    related_nodes.map{|node| extract_label(node) }
  end

  def extract_label(node)
    node.xpath('./rdfs:label').text
  end

  def build_path(parent_path, label)
    label.empty? ? "" : "#{parent_path}/#{label}"
  end

  def extract_subject(node)
    node.attr('rdf:about')
  end

  def extract_subclass_nodes(subject)
    @xml.xpath "//owl:Class[rdfs:subClassOf[@rdf:resource='#{subject}']]"
  end

  def extract_xml_from_zip
    open('temp.zip', 'wb') { |file| file << open(@resource).read }

    content = ''
    Zip::File.open('temp.zip') do |zip_file|
      zip_file.each do |entry|
        content += entry.get_input_stream.read if entry.name.end_with?('.owl')
      end
    end

    File.delete('temp.zip')
    Nokogiri::XML(content)
  end
end

 

