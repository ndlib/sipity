require "rails_helper"
require 'sipity/conversions/convert_to_json_api_link'

module Sipity
  module Conversions
    RSpec.describe ConvertToJsonApiLink do

      def self.test_for(pagination, pager: {}, query_parameters: {}, expected:)
        context "with pager: #{pager.inspect} and query_parameters: #{query_parameters.inspect}" do
          it "should equal #{expected.inspect}" do
            request = double(query_parameters: query_parameters, scheme: 'http', host_with_port: 'hello.com:3000', path: '/world')
            pager = double({ last_page?: false, first_page?: false }.merge(pager))
            expect(described_class.call(pagination, pager: pager, request: request)).to eq(expected)
          end
        end
      end

      context 'test Kaminari' do
        it 'works with the current version' do
          request = double(query_parameters: {}, scheme: 'http', host_with_port: 'hello.com:3000', path: '/world')
          pager = Sipity::Models::Work.page(1)
          described_class.call(:self, pager: pager, request: request)
          described_class.call(:first, pager: pager, request: request)
          described_class.call(:prev, pager: pager, request: request)
          described_class.call(:next, pager: pager, request: request)
          described_class.call(:last, pager: pager, request: request)
        end
      end

      context 'when on the last page' do
        test_for(:self, pager: { last_page?: true }, expected: "http://hello.com:3000/world")
        test_for(:self, pager: { last_page?: true }, query_parameters: { page: 2 }, expected: "http://hello.com:3000/world?page=2")
        test_for(:first, pager: { last_page?: true }, expected: "http://hello.com:3000/world?page=1")
        test_for(:next, pager: { last_page?: true }, expected: nil)
        test_for(:prev, pager: { last_page?: true, prev_page: 2 }, expected: "http://hello.com:3000/world?page=2")
        test_for(:last, pager: { last_page?: true, total_pages: 4 }, expected: "http://hello.com:3000/world?page=4")
      end
      context 'when on a middle page' do
        test_for(:self, query_parameters: { page: 2 }, expected: "http://hello.com:3000/world?page=2")
        test_for(:first, expected: "http://hello.com:3000/world?page=1")
        test_for(:next, pager: { next_page: 2 }, expected: "http://hello.com:3000/world?page=2")
        test_for(:prev, pager: { prev_page: 2 }, expected: "http://hello.com:3000/world?page=2")
        test_for(:last, pager: { total_pages: 4 }, expected: "http://hello.com:3000/world?page=4")
        test_for(:last, pager: { total_pages: 4 }, query_parameters: { page: 2 }, expected: "http://hello.com:3000/world?page=4")
      end
      context 'when on the first page' do
        test_for(:first, pager: { first_page?: true }, expected: "http://hello.com:3000/world?page=1")
        test_for(:self, pager: { first_page?: true }, expected: "http://hello.com:3000/world")
        test_for(:prev, pager: { first_page?: true }, expected: nil)
        test_for(:next, pager: { first_page?: true, next_page: 2 }, expected: "http://hello.com:3000/world?page=2")
        test_for(:last, pager: { first_page?: true, total_pages: 4 }, expected: "http://hello.com:3000/world?page=4")
      end
    end
  end
end
