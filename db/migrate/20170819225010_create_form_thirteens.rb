class CreateFormThirteens < ActiveRecord::Migration[5.1]
  def change
    create_table :form_thirteens do |t|
      t.string :form_type
      t.string :file_number
      t.string :film_number
      t.string :description
      t.string :name_of_issue
      t.string :title_of_class
      t.string :cusip
      t.integer :value
      t.integer :shares_or_principle_amt
      t.string :shares_or_principle
      t.string :put_or_call
      t.string :investment_desc
      t.string :other_manager
      t.integer :sole_number
      t.integer :shared_number
      t.integer :none_number
      t.index :cusip
      
      t.timestamps
    end
  end
end
