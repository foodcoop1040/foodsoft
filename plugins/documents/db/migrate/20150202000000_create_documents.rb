class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :name
      t.binary :content, limit: 16.megabyte
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :documents
  end
end
