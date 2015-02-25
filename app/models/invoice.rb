class Invoice < ActiveRecord::Base

  belongs_to :supplier
  belongs_to :delivery
  belongs_to :order

  validates_presence_of :supplier_id
  validates_numericality_of :amount, :deposit, :deposit_credit

  scope :unpaid, -> { where(paid_on: nil) }

  attr_accessor :delete_attachment

  # Replace numeric seperator with database format
  localize_input_of :amount, :deposit, :deposit_credit

  def attachment=(incoming_file)
    self.attachment_data = incoming_file.read
    self.attachment_mime = incoming_file.content_type
  end

  def delete_attachment=(value)
    if value == '1'
      self.attachment_data = nil
      self.attachment_mime = nil
    end
  end

  # Amount without deposit
  def net_amount
    amount - deposit + deposit_credit
  end
end


