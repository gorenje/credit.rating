class AddBicToFigoSupportedBank < ActiveRecord::Migration[4.2]
  def change
    add_column :figo_supported_banks, :bic, :string
  end
end
