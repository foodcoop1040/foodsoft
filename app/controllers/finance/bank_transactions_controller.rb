class Finance::BankTransactionsController < ApplicationController
  before_filter :authenticate_finance
  inherit_resources

  def index
    if params["sort"]
      sort = case params["sort"]
               when "booking_date" then "booking_date"
               when "amount" then "amount"
               when "checked_by" then "users.nick, users.first_name, users.last_name"
               when "booking_date_reverse" then "booking_date DESC"
               when "amount_reverse" then "amount DESC"
               when "checked_by_reverse" then "users.nick DESC, users.first_name DESC, users.last_name DESC"
             end
    else
      sort = "import_id DESC"
    end

    @bank_account = BankAccount.find(params[:bank_account_id])
    @bank_transactions = BankTransaction.includes(:checked_by).order(sort)
    @bank_transactions = @bank_transactions.where('reference LIKE ? OR text LIKE ?', "%#{params[:query]}%", "%#{params[:query]}%") unless params[:query].nil?
    @bank_transactions = @bank_transactions.page(params[:page]).per(@per_page)
  end

  def show
    @bank_transaction = BankTransaction.find(params[:id])
    @user = User.find_by_iban @bank_transaction.iban
  end

  def mark_checked
    @bank_transaction = BankTransaction.find(params[:id])
    @bank_transaction.update_attributes checked_at: Time.now, checked_by: current_user
    redirect_to finance_bank_account_transactions_url(@bank_transaction.bank_account), :notice => I18n.t('bank_transaction.controller.mark_checked.notice')
  end
end
