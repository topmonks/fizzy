class AddHoursToCards < ActiveRecord::Migration[8.2]
  def change
    add_column :cards, :estimate_hours, :decimal, precision: 8, scale: 2
    add_column :cards, :actual_hours, :decimal, precision: 8, scale: 2
  end
end
