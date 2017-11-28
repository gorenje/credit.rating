class AddFigoSupportedBanks < ActiveRecord::Migration[4.2]
  def change
    create_table :figo_supported_banks do |t|
      t.string :bank_name
      t.string :bank_code, :index => true
      t.text   :advice
      t.text   :details_json
    end
  end
end
