require 'rails_helper'
require 'active_model/validations'
require 'http_url_validator'

describe HttpUrlValidator do
  let(:validatable_not_allowing_empty) do
    Class.new do
      def self.name
        'ValidatableNotAllowingEmpty'
      end
      include ActiveModel::Validations
      attr_accessor :an_http_url
      validates :an_http_url, http_url: true
    end
  end

  let(:validatable_allowing_empty) do
    Class.new do
      def self.name
        'ValidatableAllowingEmpty'
      end
      include ActiveModel::Validations
      attr_accessor :an_http_url
      validates :an_http_url, http_url: { allow_empty: true }
    end
  end

  let(:record_not_allowing_empty) { validatable_not_allowing_empty.new }
  let(:record_allowing_empty) { validatable_allowing_empty.new }

  context '#valid?' do
    VALID_EXPECTATIONS = {
      true => :to,
      false => :not_to
    }.freeze

    def self.assert_validation(url:, valid:, allow_empty: false)
      valid_expectation = VALID_EXPECTATIONS.fetch(valid)
      allow_empty_message = allow_empty ? '' : 'do not'
      it "is expected #{valid_expectation.to_s.humanize.downcase} be valid for #{url} when we #{allow_empty_message} allow empty" do
        record = allow_empty ? record_allowing_empty : record_not_allowing_empty
        record.an_http_url = url
        expect(record).send(valid_expectation, be_valid)
        expect(record.errors.messages).send(valid_expectation, be_empty)
      end
    end

    assert_validation(url: "https://google.com", valid: true)
    assert_validation(url: "http://google.com", valid: true)
    assert_validation(url: "ftp://google.com", valid: false)
    assert_validation(url: "google.com", valid: false)
    assert_validation(url: 'https://google.com\\', valid: false)
    assert_validation(url: '', valid: true, allow_empty: true)
    assert_validation(url: '', valid: false, allow_empty: false)
    assert_validation(url: nil, valid: false, allow_empty: false)
    assert_validation(url: nil, valid: true, allow_empty: true)
  end
end
