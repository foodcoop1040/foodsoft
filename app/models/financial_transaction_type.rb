class FinancialTransactionType < ActiveRecord::Base
  belongs_to :financial_transaction_class
  has_many :financial_transactions, dependent: :restrict_with_exception

  validates :name, presence: true
  validates_uniqueness_of :name
  validates :financial_transaction_class, presence: true

  before_destroy :check_last_financial_transaction_type

  def self.default
    first
  end

  protected

  # check if this is the last financial transaction type and deny
  def check_last_financial_transaction_type
    raise I18n.t('model.financial_transaction_type.no_delete_last') if FinancialTransactionType.count == 1
  end
end
