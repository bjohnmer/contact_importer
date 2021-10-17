require 'rails_helper'

RSpec.describe ImportSummary, type: :model do
  describe 'associations' do
    it { should belong_to(:imported_file) }
  end
end
