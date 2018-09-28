class AddColorToVariations < ActiveRecord::Migration[5.2]
  def change
    add_reference :variations, :color, foreign_key: true
  end
end
