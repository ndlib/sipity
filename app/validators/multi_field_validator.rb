# This class is used for validating multi-field values
class MultiFieldValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, values)
    Array.wrap(values).each do |value|
      record.errors.add(:invalid_value, "Cannot have blank values") if value.blank?
    end
    return true
  end
end
