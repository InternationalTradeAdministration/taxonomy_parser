module PostProcessing

  private

  def post_processing
    combined = @concepts + @concept_groups + @concept_schemes
    combined.each do |term|
      assign_labels_to_parents(term)
      assign_labels_to_properties(term)
    end
  end

  def assign_labels_to_parents(term)
    term[:subClassOf].delete_if do |parent|
      parent_term = find_by_id(parent[:id])
      if (parent_term.nil? || parent_term[:subject] == term[:subject])
        true
      else
        parent[:label] = parent_term[:label]
        false
      end
    end
  end

  def assign_labels_to_properties(term)
    term[:object_properties].each do |property_key, array|
      array.each do |obj_prop|
      property_target_term = find_by_id(obj_prop[:id])
        obj_prop[:label] = property_target_term[:label] unless property_target_term.nil? 
      end
    end
  end
end