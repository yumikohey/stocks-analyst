class AddFiledDateToFormThirteen < ActiveRecord::Migration[5.1]
  def change
    add_column :form_thirteens, :filed_date, :date
  end
end
