require "rails_helper"
require 'sipity/controllers/work_areas/filter_form_presenter'

RSpec.describe Sipity::Controllers::WorkAreas::FilterFormPresenter do
  let(:context) { PresenterHelper::ContextWithForm.new }
  let(:work_area) do
    double(
      input_name_for_select_processing_states: 'hello[world][]',
      processing_states: ['new'],
      processing_states_for_select: ['new', 'say'],
      input_name_for_select_sort_order: 'name[sort_order]',
      order_options_for_select: ['title', 'created_at'],
      input_name_for_selecting_submission_window: 'name[submission_window]',
      input_name_for_q: 'name[q]',
      q: 'Searching for',
      submission_window: '2017',
      submission_windows_for_select: ['2016', '2017'],
      order: 'title'
    )
  end

  subject { described_class.new(context, work_area: work_area) }

  its(:submit_button) { is_expected.to be_html_safe }
  its(:select_tag_for_processing_states) { is_expected.to be_html_safe }

  it 'will expose q_tag' do
    expect(subject.q_tag).to have_tag('input[type="text"][value="Searching for"][name="name[q]"]')
  end

  it 'will expose select_tag_for_processing_states' do
    expect(subject.select_tag_for_processing_states).to have_tag('select[name="hello[world][]"]') do
      with_tag("option[value='']", text: 'All states')
      with_tag("option[value='new'][selected='selected']", text: 'New')
      with_tag("option[value='say']", text: 'Say')
    end
  end

  it 'will expose select_tag_for_submission_window' do
    expect(subject.select_tag_for_submission_window).to have_tag('select[name="name[submission_window]"]') do
      with_tag("option[value='']", text: '')
      with_tag("option[value='2017'][selected='selected']", text: '2017')
      with_tag("option[value='2016']", text: '2016')
    end
  end

  it 'will expose select_tag_for_sort_order' do
    expect(subject.select_tag_for_sort_order).to have_tag('select[name="name[sort_order]"]') do
      with_tag("option[value='title'][selected='selected']", text: 'Title')
      with_tag("option[value='created_at']", text: 'Created at')
    end
  end

  it 'will have a submit button' do
    expect(subject.submit_button).to have_tag('input.btn.btn-primary[type="submit"]')
  end
end
