
module PostProcessing

  private

  def perform_additional_processing
    assign_labels_to_parents(@concept_groups)
    assign_labels_to_parents(@concepts)

    assign_labels_to_property_hashes
  end

  def build_paths
    combined = @concepts + @concept_groups + @concept_schemes

  end

  def assign_labels_to_parents(terms)
    terms.each do |term|
      term[:subClassOf].delete_if do |parent|
        parent_term = find_by_id(parent[:id], terms)
        if parent_term.nil?
          true
        else
          parent[:label] = parent_term[:label]
          false
        end
      end
    end
  end

  def assign_labels_to_property_hashes
    combined = @concepts + @concept_groups + @concept_schemes
    combined.each do |term|
      term[:object_properties].each do |property_key, array|
        array.each do |obj_prop|
        property_target_term = find_by_id(obj_prop[:id], combined)
          obj_prop[:label] = property_target_term[:label] unless property_target_term.nil? 
        end
      end
    end
  end

end