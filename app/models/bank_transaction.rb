class BankTransaction < ActiveRecord::Base

  belongs_to :bank_account
  belongs_to :checked_by, :class_name => 'User', :foreign_key => 'checked_by_user_id'

  validates_presence_of :booking_date, :amount, :bank_account_id
  validates_numericality_of :amount

  # Replace numeric seperator with database format
  localize_input_of :amount

  def image_url
    'data:image/png;base64,' + Base64.encode64(self.image)
  end
end
