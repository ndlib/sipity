require 'rails_helper'

feature 'Minimum viable SIP', :devise do
  include Warden::Test::Helpers
  before { Warden.test_mode! }
  let(:user) { Sipity::Factories.create_user }
  scenario 'User can create a SIP' do
    login_as(user, scope: :user)
    visit '/start'
    on('new_sip_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:title, with: 'Hello World')
      the_page.select('ETD', from: :work_type)
      the_page.choose(:work_publication_strategy, with: 'do_not_know')
      the_page.submit_button.click
    end

    on('sip_page') do |the_page|
      expect(the_page.text_for('title')).to eq(['Hello World'])
      expect(the_page.text_for('work_publication_strategy')).to eq(['do_not_know'])
      the_page.click_recommendation('DOI')
    end

    on('assign_doi_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:identifier, with: 'abc:123')
      the_page.submit_button.click
    end

    on('sip_page') do |the_page|
      the_page.click_edit
    end

    on('edit_sip_page') do |the_page|
      the_page.fill_in(:title, with: 'New Value')
      the_page.submit_button.click
    end

    on('sip_page') do |the_page|
      expect(the_page.text_for('title')).to eq(['New Value'])
      the_page.click_recommendation('Citation')
    end

    on('new_citation_page') do |the_page|
      the_page.fill_in(:citation, with: 'This is My Citation')
      the_page.fill_in(:type, with: 'ALA')
      the_page.submit_button.click
    end
  end

  # Given a user has filled out a publication date at creation
  # When they go to request a DOI
  # Then the publication_date is displayed
  # And cannot be changed

end
