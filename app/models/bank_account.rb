class BankAccount < ActiveRecord::Base

  has_many :bank_transactions

  normalize_attributes :name, :iban, :description

  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 2 }
  validates :iban, :presence => true, :uniqueness => true
  validates_numericality_of :balance, :message => I18n.t('bank_account.model.invalid_balance')

  before_destroy :check_for_associated_bank_transactions

  protected

  # Deny deleting the bank account when there are associated transactions.
  def check_for_associated_bank_transactions
#    raise I18n.t('activerecord.errors.has_many_left', collection: BankTransaction.model_name.human) if bank_transactions.undeleted.exists?
  end
end
