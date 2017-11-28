class InitialTables < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string   :email, :index => true
      t.string   :name
      t.hstore   :address
      t.boolean  :email_verified
      t.string   :language
      t.datetime :join_date
      t.text     :credentials

      t.string  :salt
      t.string  :confirm_token
      t.boolean :has_confirmed, :default => false

      t.hstore :last_import_attempt_status
      t.datetime :last_successful_import, :index => true

      t.timestamps :null => false
    end

    create_table :accounts do |t|
      t.string  :figo_account_id
      t.string  :owner
      t.string  :name
      t.string  :account_number
      t.string  :currency
      t.string  :iban
      t.string  :account_type
      t.text    :icon_url
      t.decimal :last_known_balance

      t.string  :sepa_creditor_id
      t.boolean :save_pin
      t.text    :credentials

      t.belongs_to :user
      t.belongs_to :bank
      t.timestamps :null => false
    end

    add_index :accounts, [:user_id, :figo_account_id]

    create_table :banks do |t|
      t.string  :figo_bank_id, :index => true
      t.string  :figo_bank_code
      t.string  :figo_bank_name

      t.string  :iban_bank_code, :index => true
      t.string  :iban_bank_name

      t.timestamps :null => false
    end

    create_table :transactions do |t|
      t.string  :transaction_id, :index => true
      t.string  :name
      t.decimal :amount
      t.string  :currency
      t.date    :booking_date
      t.date    :value_date
      t.boolean :booked
      t.text    :booking_text
      t.text    :purpose
      t.text    :transaction_type
      t.hstore  :extras

      t.string :classname
      t.belongs_to :account
      t.timestamps :null => false
    end

    add_index :transactions, [:account_id, :transaction_id]
  end
end
