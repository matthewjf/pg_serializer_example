class Category < ApplicationRecord
  has_and_belongs_to_many :products

  serializable do
    attributes :name, :id
  end
end
