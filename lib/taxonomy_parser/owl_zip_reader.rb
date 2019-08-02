module OwlZipReader
  def self.read(url)
    Tempfile.open(%w(protege .zip), encoding: 'ascii-8bit') do |f|
      f.write(open(url).read)
      f.close

      Zip::File.open(f.path) do |zip_file|
        paths = zip_file.select do |path|
          path.name.end_with? '.owl'
        end
        ConsolidatedXmlDocument.parse(*paths.map(&:get_input_stream))
      end
    end
  end
end
