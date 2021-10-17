require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe '#index' do
    context 'when not signed in' do
      it 'should not respond with success' do
        get :index
        expect(response).to_not be_successful
      end
    end

    context 'when signed in' do
      let(:user) { create(:user)}
      it 'responds with success' do
        sign_in user

        get :index
        expect(response).to be_successful
      end
    end
  end
end
