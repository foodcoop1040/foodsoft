# financial transactions are the foodcoop internal financial transactions
# only ordergroups have an account  balance and are happy to transfer money
class FinancialTransaction < ApplicationRecord
  belongs_to :ordergroup
  belongs_to :user
  belongs_to :financial_link
  belongs_to :financial_transaction_type
  belongs_to :reverts, class_name: 'FinancialTransaction', foreign_key: 'reverts_id'
  has_one :reverted_by, class_name: 'FinancialTransaction', foreign_key: 'reverts_id'

  validates_presence_of :amount, :note, :user_id, :ordergroup_id
  validates_numericality_of :amount, greater_then: -100_000,
    less_than: 100_000

  scope :visible, -> { joins('LEFT JOIN financial_transactions r ON financial_transactions.id = r.reverts_id').where('r.id IS NULL').where(reverts: nil) }
  scope :without_financial_link, -> { where(financial_link: nil) }

  localize_input_of :amount

  after_initialize do
    initialize_financial_transaction_type
  end

  # @todo remove alias (and rename created_on to created_at below) after #575
  ransack_alias :created_at, :created_on

  def self.ransackable_attributes(auth_object = nil)
    %w(id amount note created_on user_id financial_transaction_type_id)
  end

  def self.ransackable_associations(auth_object = nil)
    %w() # none, and certainly not user until we've secured that more
  end

  # Use this save method instead of simple save and after callback
  def add_transaction!
    ordergroup.add_financial_transaction! amount, note, user, financial_transaction_type
  end

  def revert!(user)
    transaction do
      rt = dup
      rt.amount = -rt.amount
      rt.reverts = self
      rt.user = user
      rt.save!
      ordergroup.update_balance!
    end
  end

  def hidden?
    reverts.present? || reverted_by.present?
  end

  # @todo rename in model, see #575
  def created_at
    created_on
  end

  protected

  def initialize_financial_transaction_type
    self.financial_transaction_type ||= FinancialTransactionType.default
  end
end
