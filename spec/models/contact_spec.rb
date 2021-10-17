require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { create(:contact) }

    context 'presences' do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:dob) }
      it { should validate_presence_of(:phone) }
      it { should validate_presence_of(:address) }
      it { should validate_presence_of(:credit_card) }
      it { should validate_presence_of(:email) }
      it { should validate_presence_of(:user) }
    end

    context 'values' do
      it { should allow_value(Faker::Name.first_name).for :name }
      it { should_not allow_value('John-', 'Te-st').for :name }

      it { should allow_value(Faker::Finance.credit_card(:mastercard).delete('-')).for :credit_card }
      it { should_not allow_value('etretrtr', '09').for :credit_card }

      it { should allow_value('hola@test.com', 'hola@test.com.ec').for :email }
      it { should_not allow_value('holatest.com', 'hey').for :email }
    end

    it { should validate_uniqueness_of(:email).scoped_to(:user_id) }
  end

  describe 'callbacks' do
    it 'sets franchise' do
      new_contact = create(:contact, credit_card: Faker::Finance.credit_card(:visa).delete('-'))
      expect(new_contact.franchise).to eq('VISA')
    end
  end
end
