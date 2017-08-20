class CreateSplits < ActiveRecord::Migration[5.1]
  def change
    create_table :splits do |t|
      t.string :symbol
      t.date :date
      t.string :content
      t.index :symbol
      
      t.timestamps
    end
  end
end
