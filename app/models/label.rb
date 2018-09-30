class Label < ApplicationRecord
  has_many :products

  pg_serializable do
    attributes :name, :id
  end
end
