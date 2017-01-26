require 'easybank'
require 'roo'

class BankAccount < ActiveRecord::Base

  has_many :bank_transactions, dependent: :destroy

  normalize_attributes :name, :iban, :description

  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 2 }
  validates :iban, :presence => true, :uniqueness => true
  validates_format_of :iban, :with => /\A[A-Z]{2}[0-9]{2}[0-9A-Z]{,30}\z/
  validates_numericality_of :balance, :message => I18n.t('bank_account.model.invalid_balance')

  def import_from_file(file, options = {})
    options[:csv_options] = {col_sep: ';', encoding: 'utf-8'}.merge(options[:csv_options]||{})
    s = Roo::Spreadsheet.open(file.to_path, options)

    count = -1
    s.each do |row|
      if count == -1
        # @todo try to detect headers; for now using the index is ok
      else
        bank_transactions.where(:import_id => row[0].to_i).first_or_create.update(
                       :booking_date => row[1],
                       :value_date => row[2],
                       :amount => row[3],
                       :booking_type => row[4],
                       :iban => row[5],
                       :reference => row[6],
                       :text => row[7],
                       :receipt => row[8],
                       :image => row[9].nil? ? nil : Base64.decode64(row[9]))
      end
      count += 1
    end
    count
  end

  def find_import_method
    # TODO: Move lookup for import function into plugin
    return method(:import_from_easybank) if /^AT\d{2}14200\d{11}$/.match(iban)
  end

  def assign_unchecked_transactions
    count = 0
    bank_transactions.unchecked.each do |t|
      m = /^\d+$/.match(t.reference)
      next unless m

      amount_credit = 0
      amount_deposit = 0
      amount_membership = 0

      all_2 = true
      found_3 = false
      ref = t.reference.to_i.to_s

      ref.each_char { |c|
        all_2 = false if c != '2'
        case c
        when '1'
          if ref.length == 1
            amount_deposit = t.amount
          else
            amount_deposit += 30
          end
        when '2'
          if ref.length == 1
            amount_membership = t.amount
          else
            amount_membership += 10
          end
        when '3'
          found_3 = true
        end
      }

      amount_membership = t.amount if all_2
      amount_credit = t.amount - amount_deposit - amount_membership if found_3
      next if t.amount != amount_credit + amount_membership + amount_deposit
      user = User.find_by_iban(t.iban)
      next if user.nil?
      ordergroup = user.ordergroup
      next if ordergroup.nil?

      ActiveRecord::Base.transaction do
        note = "ID=#{t.id} (EUR #{t.amount})"
        ordergroup.add_financial_transaction! amount_deposit, note, user, FinancialTransactionType.find(1) if amount_deposit > 0
        ordergroup.add_financial_transaction! amount_membership, note, user, FinancialTransactionType.find(2) if amount_membership > 0
        ordergroup.add_financial_transaction! amount_credit, note, user, FinancialTransactionType.find(3) if amount_credit > 0
        t.update_attributes checked_at: Time.now, checked_by: user
        count += 1
      end
    end
    count
  end

  private

  def import_from_easybank(bank_account)
    easybank_config = FoodsoftConfig[:easybank]
    raise "easybank configuration missing" if not easybank_config

    dn = easybank_config[:dn]
    pin = easybank_config[:pin]
    account = bank_account.iban[-11,11]

    count = 0
    last_import_id = nil

    Easybank.login(dn, pin) do |eb|
      bank_account.balance = eb.balance(account)
      eb.transactions(account, bank_account.last_import_id).each do |t|
        bank_account.bank_transactions.where(:import_id => t[:id]).first_or_create.update(
          :booking_date => t[:booking_date],
          :value_date => t[:value_date],
          :amount => t[:amount],
          :booking_type => t[:type],
          :iban => t[:iban],
          :reference => t[:reference] ? t[:reference] : t[:reference2],
          :text => t[:raw],
          :receipt => t[:receipt],
          :image => t[:image])

        count += 1
        last_import_id = t[:id]
      end
    end

    bank_account.last_import = Time.now
    bank_account.last_import_id = last_import_id unless last_import_id.nil?
    bank_account.save!

    return count
  end
end
