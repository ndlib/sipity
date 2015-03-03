require 'rails_helper'

module Sipity
  module Models
    RSpec.describe AccessRight, type: :model do
      subject { described_class }
      its(:column_names) { should include('entity_id') }
      its(:column_names) { should include('entity_type') }
      its(:column_names) { should include('access_right_code') }
      its(:column_names) { should include('enforcement_start_date') }
      its(:column_names) { should include('enforcement_end_date') }
      its(:primative_acccess_right_codes) { should be_a(Array) }
    end
  end
end
