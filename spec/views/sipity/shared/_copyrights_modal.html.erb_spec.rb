require 'rails_helper'

RSpec.describe 'sipity/shared/_copyrights_modal.html.erb', type: :view do
  it 'renders the page in a ' do
    render template: 'sipity/shared/_copyrights_modal.html.erb'
    expect(rendered).to be_a(String)
  end
end
