require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  let(:user) { create(:user, :with_contacts) }

  before do
    sign_in user
  end

  describe '#index' do
    let(:other_user) { create(:user) }
    let(:other_user_contacts) { create_list(:contact, 2, user: other_user) }


    it 'set the contacts per the current user' do
      get :index
      expect(assigns(:contacts).count).to eq(2)
    end
  end
end
