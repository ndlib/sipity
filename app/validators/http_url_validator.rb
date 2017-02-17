require 'active_model/validator'
require 'uri'

# Validates that we have an HTTP or HTTPS URL
class HttpUrlValidator < ActiveModel::EachValidator
  def self.compliant?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    return true if (value.nil? || value.empty?) && allow_empty?
    return true if value.present? && self.class.compliant?(value)
    record.errors.add(attribute, "is not a valid HTTP(S) URL")
  end

  private

  def allow_empty?
    options.fetch(:allow_empty, false)
  end
end
