class ContactsController < ApplicationController
  before_action :authenticate_user!

  def index
    @contacts = current_user.contacts.order(:name).page(params[:page]).per(10)
  end
end
