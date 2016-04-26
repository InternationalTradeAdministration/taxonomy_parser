module PostProcessor

  def self.process_terms(parser)
    parser.terms.each do |term|
      assign_labels_to_parents(term, parser)
      assign_labels_to_properties(term, parser)
    end
  end

  private

  def self.assign_labels_to_parents(term, parser)
    term[:sub_class_of].delete_if do |parent|
      parent_term = parser.find_by_id(parent[:id])
      if (parent_term.nil? || parent_term[:subject] == term[:subject])
        true
      else
        parent[:label] = parent_term[:label]
        false
      end
    end
  end

  def self.assign_labels_to_properties(term, parser)
    term[:object_properties].each do |property_key, array|
      array.each do |obj_prop|
      property_target_term = parser.find_by_id(obj_prop[:id])
        obj_prop[:label] = property_target_term[:label] unless property_target_term.nil? 
      end
    end
  end
end