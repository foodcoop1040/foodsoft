class AddInvoiceAttachment < ActiveRecord::Migration
  def self.up
    add_column :invoices, :attachment_mime, :string
    add_column :invoices, :attachment_data, :binary, :limit => 8.megabyte
  end

  def self.down
    remove_column :invoices, :attachment_data
    remove_column :invoices, :attachment_mime
  end
end
