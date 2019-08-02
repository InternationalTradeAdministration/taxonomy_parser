module ConsolidatedXmlDocument
  def self.parse(*ios)
    content = '<?xml version="1.0"?><root>'
    ios.each do |io|
      file_content = io.read
      content << file_content.sub('^<?xml version="1.0"?>', '')
    end
    content << '</root>'

    Nokogiri::XML.parse content
  end
end
