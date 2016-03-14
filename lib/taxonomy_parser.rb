require 'taxonomy_parser/version'
require 'nokogiri'
require 'open-uri'
require 'zip'
require 'tempfile'
Dir[File.dirname(__FILE__) + "/taxonomy_parser/modules/*.rb"].each {|file| require file }

class TaxonomyParser
  include LookupMethods
  include PropertyExtractor
  include PostProcessing
  CONCEPT_GROUP_IRI = 'http://purl.org/iso25964/skos-thes#ConceptGroup'
  CONCEPT_IRI = 'http://www.w3.org/2004/02/skos/core#Concept'
  CONCEPT_SCHEME_IRI = 'http://www.w3.org/2004/02/skos/core#ConceptScheme'

  attr_accessor :concept_groups, :concepts, :concept_schemes, :raw_source

  def initialize(resource)
    @resource = resource
    @concepts = []
    @concept_groups = []
    @concept_schemes = []
    @raw_source = extract_xml_from_zip
    @xml = Nokogiri::XML(@raw_source)
    @xml.remove_namespaces!
  end

  def parse
    extract_terms(@concept_groups, CONCEPT_GROUP_IRI)
    extract_terms(@concepts, CONCEPT_IRI)
    extract_terms(@concept_schemes, CONCEPT_SCHEME_IRI)
    post_processing
  end

  private

  def extract_terms(terms, iri)
    root_node = @xml.xpath("//Class[@about='#{iri}']").first
    root_node_hash = extract_node_hash(root_node)
    process_subclass_nodes(root_node_hash) do |node_hash|
      terms.push node_hash
    end
  end

  def process_subclass_nodes(node_hash, &block)
    node_hash[:subclass_nodes].each do |child_node|
      child_node_hash = extract_node_hash(child_node)
      next if child_node_hash[:subject] == node_hash[:subject] # Handle case where class is parent of itself... gotta love Protege!
      yield child_node_hash.reject{ |k| k == :subclass_nodes }
      process_subclass_nodes(child_node_hash, &block)
    end
  end

  def extract_node_hash(node)
    subject = extract_subject(node)
    subclass_nodes = extract_subclass_nodes(subject)
    properties = extract_properties(node)
 
    properties.merge({ 
      subclass_nodes: subclass_nodes,
      subject: subject,
      #xml_source: node.to_s,
    })
  end

  def extract_label(node)
    node.xpath('./label').text
  end

  def extract_subject(node)
    node.attr('about')
  end

  def extract_subclass_nodes(subject)
    @xml.xpath "//Class[subClassOf[@resource='#{subject}']]"
  end

  def extract_xml_from_zip
    file = Tempfile.new(['protege', '.zip'], File.dirname(__FILE__), :encoding => 'ascii-8bit')
    file.write(open(@resource).read)
    file.close

    content = '<?xml version="1.0"?><root>'
    Zip::File.open(file.path) do |zip_file|
      zip_file.each do |entry|
        content << entry.get_input_stream.read if entry.name.end_with?('.owl')
      end
    end

    file.unlink
    content << '</root>'
    content
  end
end