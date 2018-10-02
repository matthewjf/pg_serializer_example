class Label < ApplicationRecord
  has_many :products

  serializable do
    attributes :name, :id
  end
end
