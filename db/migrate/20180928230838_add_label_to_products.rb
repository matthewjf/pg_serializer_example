class AddLabelToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :label, foreign_key: true
  end
end
