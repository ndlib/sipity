require 'rails_helper'
require 'byebug'

feature 'Enriching a Work', :devise, :feature do
  include Warden::Test::Helpers
  before do
    path = Rails.root.join('app/data_generators/sipity/data_generators/work_areas/etd_work_area.config.json')
    Sipity::DataGenerators::WorkAreaGenerator.call(path: path)
    Warden.test_mode!
  end
  let(:user) { Sipity::Factories.create_user(agreed_to_terms_of_service: true) }

  def create_a_work(options = {})
    visit '/start'
    on('new_work_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:title, with: options.fetch(:title, 'Hello World'))
      the_page.select(options.fetch(:work_type, 'doctoral_dissertation'), from: :work_type)
      the_page.choose(:work_publication_strategy, with: options.fetch(:work_publication_strategy, 'do_not_know'))
      the_page.choose(:work_patent_strategy, with: options.fetch(:work_patent_strategy, 'do_not_know'))
      the_page.fill_in(:permanent_email, with: options.fetch(:permanent_email, "someone@example.com"))
      the_page.submit_button.click
    end
  end

  scenario "User can enrich their submission after they agree to ToS" do
    user = Sipity::Factories.create_user(agreed_to_terms_of_service: false)
    login_as(user, scope: :user)
    visit '/start'
    expect(page.current_path).to eq("/account/")
    on("account_page") do |the_page|
      the_page.preferred_name.set("My Preferred Name")
      the_page.agree_to_tos.check
      the_page.submit_button.click
    end
    # We have passed the threshold for agreeing to the terms of service
    on('new_work_page') do |the_page|
      expect(the_page).to be_all_there
    end
  end

  scenario 'User can enrich their submission' do
    user = Sipity::Factories.create_user(agreed_to_terms_of_service: true)
    login_as(user, scope: :user)
    create_a_work(work_type: 'doctoral_dissertation', title: 'Hello World', work_publication_strategy: 'do_not_know', permanent_email: 'someone@example.com')

    on('work_page') do |the_page|
      # There are two because it is listed as a top-level attribute and as part
      # of the access rights.
      expect(the_page.text_for('title')).to eq(['Hello World', 'Hello World'])
      the_page.click_todo_item('enrichment/required/describe')
    end

    on('describe_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:abstract, with: 'Lorem ipsum')
      the_page.submit_button.click
    end

    on('work_page') do |the_page|
      expect(the_page.todo_item_named_status_for('enrichment/required/describe')).to eq('done')
      the_page.click_todo_item('enrichment/required/attach')
    end

    # User will see their attachments
    on('attach_page') do |the_page|
      expect(the_page).to have_input_file
      the_page.attach_file(__FILE__)
      the_page.submit_button.click
    end

    # And it shows up on the dashboard
    visit '/dashboard'
      # The first text is empty because it displays the glyphicon
    expect(page.all(".work-listing a").map(&:text)).to eq(['', 'Hello World'])
  end
end
