require 'rails_helper'
require 'sipity/queries/simple_controlled_vocabulary_queries'

module Sipity
  module Queries
    RSpec.describe SimpleControlledVocabularyQueries, type: :isolated_repository_module do
      context '#get_controlled_vocabulary_values_for_predicate_name' do
        it 'will get all the values associated with predicate_name' do
          response = test_repository.get_controlled_vocabulary_values_for_predicate_name(name: 'program_name')
          expect(response).to be_a(Enumerable)
          expect(response).to be_present

          expect(response.all? { |obj| obj.is_a?(String) }).to be_truthy
        end
      end

      context '#get_controlled_vocabulary_entries_for_predicate_name' do
        it 'will get records associated with predicate_name' do
          response = test_repository.get_controlled_vocabulary_entries_for_predicate_name(name: 'program_name')
          expect(response).to be_a(Enumerable)
          expect(response).to be_present
          expect(response.all? { |obj| obj.respond_to?(:term_uri) && obj.respond_to?(:term_label) }).to be_truthy
        end
      end

      context '#get_controlled_vocabulary_value_for' do
        it 'will get controlled vocabulary label for the predicate and uri' do
          uri = 'http://creativecommons.org/publicdomain/mark/1.0/'
          label = "Public Domain Mark 1.0"
          expect(test_repository.get_controlled_vocabulary_value_for(name: 'copyright', term_uri: uri)).to eq(label)
        end

        it 'will default to the given uri if nothing is found' do
          uri = 'http://test.com'
          expect(test_repository.get_controlled_vocabulary_value_for(name: 'copyright', term_uri: uri)).to eq(uri)
        end
      end

      context '#get_active_hierarchical_roots_for_predicate_name' do
        it 'will get records hierarchical roots for predicate_name' do
          response = test_repository.get_controlled_vocabulary_entries_for_predicate_name(name: 'administrative_units')
          expect(response).to be_a(Array)
          expect(response).to be_present
          expect(response.first).to be_a(Locabulary::Items::AdministrativeUnit)
        end
      end

      context '#prepare_hierarchical_menu_options' do
        let(:roots) { test_repository.get_active_hierarchical_roots_for_predicate_name(name: 'administrative_units') }

        it 'will get prepare menu options array' do
          response = test_repository.prepare_hierarchical_menu_options(roots: roots)
          expect(response).to be_a(Array)
          expect(response).to be_present
          expect(response.first).to be_a(Hash)
        end
      end
    end
  end
end
