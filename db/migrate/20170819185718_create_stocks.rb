class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.string :company_name
      t.string :stock_exchange
      t.string :cusip
      t.string :industry
      t.string :sector
      t.string :ipo_year
      t.index :symbol

      t.timestamps
    end
  end
end
