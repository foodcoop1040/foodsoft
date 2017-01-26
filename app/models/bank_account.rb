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
