class Contact < ApplicationRecord
  belongs_to :user

  validates_presence_of :name, :dob, :phone, :address, :credit_card, :email, :user

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { scope: :user_id }
  validate :check_credit_card
  validate :dob_is_iso8601

  validates_format_of :name, with: /\A([^-]+)\z/
  validates_format_of :phone, with: /\A(\(\+\d{1,3}\)\d{3}-\d{3}-\d{2}-\d{2}|\(\+\d{1,3}\)\d{3}\s\d{3}\s\d{2}\s\d{2})\z/

  before_save :set_franchise

  private

  def check_credit_card
    cleaned_number = credit_card&.delete('^0-9')
    cleaned_number.credit_card_bin.present?
  rescue
    errors.add(:credit_card, 'invalid')
  end

  def dob_is_iso8601
    Date.iso8601(dob.to_s)
  rescue
    errors.add(:dob, 'invalid')
  end

  def set_franchise
    cleaned_number = credit_card.delete('^0-9')
    self.franchise = cleaned_number.credit_card_bin_brand
  end
end
