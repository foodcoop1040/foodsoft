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
end
