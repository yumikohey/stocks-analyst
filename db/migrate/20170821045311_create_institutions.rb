class CreateInstitutions < ActiveRecord::Migration[5.1]
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :state
      t.string :address
      t.string :file_number
      t.string :cik

      t.timestamps
    end
  end
end
