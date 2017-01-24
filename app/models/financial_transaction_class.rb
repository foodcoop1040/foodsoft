class FinancialTransactionClass < ActiveRecord::Base
  has_many :financial_transaction_types, dependent: :destroy

  validates :name, presence: true
  validates_uniqueness_of :name

  scope :table_columns, -> { order(name: :asc) }

  def display
    if FinancialTransactionClass.count > 1
      name
    else
      I18n.t('activerecord.attributes.financial_transaction.amount')
    end
  end
end
