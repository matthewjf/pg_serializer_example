class Variation < ApplicationRecord
  belongs_to :product
  belongs_to :color

  serializable do
    attributes :name, :id
    belongs_to :color
  end
end
