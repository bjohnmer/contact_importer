require 'rails_helper'

RSpec.describe ImportedFilesController, type: :controller do
  def valid_columns
    Contact.column_names.reject { |column| %w[id franchise created_at updated_at user_id].include?(column) }
  end

  describe '#index' do
    context 'when not signed in' do
      it 'should not respond with success' do
        get :index
        expect(response).to_not be_successful
      end
    end

    context 'when signed in' do
      let(:user) { create(:user, :with_imported_files)}
      it 'responds with success' do
        sign_in user

        get :index
        expect(response).to be_successful
        expect(assigns(:imported_files).count).to eq(2)
      end
    end
  end

  describe '#upload' do
    context 'when not signed in' do
      it 'should not respond with success' do
        get :upload
        expect(response).to_not be_successful
      end
    end

    context 'when signed in' do
      let(:user) { create(:user, :with_imported_files)}
      it 'responds with success' do
        sign_in user

        get :upload
        expect(response).to be_successful
        expect(assigns(:columns)).to eq(['name', 'dob', 'phone', 'address', 'credit_card', 'email'])
      end
    end
  end

  describe '#import' do
    let(:user) { create(:user)}
    let(:valid_params) {
      params = {}
      valid_columns.each_with_index do |p, index|
        if p == 'dob'
          params["col_#{index}"] = p
          params["input_#{index}"] = 'Date of Birth'

          next
        end
        params["col_#{index}"] = p
        params["input_#{index}"] = p.humanize.titleize
      end
      params.merge!(csv_file: Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/contacts.csv", 'text/csv'))
      params
    }

    let(:invalid_params) do
      valid_params.delete(:csv_file)
      valid_params
    end

    context 'when not signed in' do
      it 'should not respond with success' do
        post :import
        expect(response).to_not be_successful
      end
    end

    context 'when signed in' do
      before do
        sign_in user
      end

      context 'with valid params' do
        it 'responds redirects and enqueue CsvGeneratorJob' do
          post :import, params: valid_params
          expect(response).to redirect_to(imported_files_index_path)
          expect(CsvGeneratorJob).to have_been_enqueued
        end
      end

      context 'with invalid params' do
        it 'responds redirects and enqueue CsvGeneratorJob' do
          post :import, params: invalid_params
          expect(response).to redirect_to(imported_files_upload_path)
        end
      end
    end
  end

  describe '#show' do
    let(:user) { create(:user, :with_imported_files)}

    context 'when not signed in' do
      it 'should not respond with success' do
        get :show, params: { id: user.imported_files.first.id }
        expect(response).to_not be_successful
      end
    end

    context 'when signed in' do
      it 'responds with success' do
        sign_in user

        get :show, params: { id: user.imported_files.first.id }

        expect(response).to be_successful
        expect(assigns(:summary)).to eq(user.imported_files.first.import_summaries.first)
      end
    end
  end
end
