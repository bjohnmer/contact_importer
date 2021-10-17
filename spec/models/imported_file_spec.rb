require 'rails_helper'

RSpec.describe ImportedFile, type: :model do
  describe 'associations' do
    subject(:imported_file) { create(:imported_file) }

    it { should belong_to(:user) }
    it { should have_many(:import_summaries) }
    it { expect(imported_file.file).to be_attached }
  end

  describe 'enumerables' do
    it { should define_enum_for(:status).with_values(%i[on_hold processing failed finished]) }
  end
end
