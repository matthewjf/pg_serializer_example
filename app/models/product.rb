class Product < ApplicationRecord
  has_many :categories_products
  has_many :categories, through: :categories_products
  has_many :variations
  belongs_to :label

  serializable do
    default do
      attributes :name, :id
      # attribute :name, label: :test_name
      has_many :variations
      belongs_to :label
      has_many :categories
    end

    trait :simple do
      attributes :id
      has_many :variations, trait: :product
    end
  end
end
