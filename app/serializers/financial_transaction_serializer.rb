class FinancialTransactionSerializer < ActiveModel::Serializer
  include ApplicationHelper

  attributes :id, :user_id, :user_name, :financial_transaction_type_id,
    :financial_transaction_type_name, :amount, :note, :created_at

  def user_name
    show_user object.user
  end

  def financial_transaction_type_name
    object.financial_transaction_type.name
  end

  def amount
    object.amount.to_f
  end
end
