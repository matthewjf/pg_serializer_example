class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  has_many :variations
  belongs_to :label

  serializable do
    attributes :name, :id
    attribute :name, label: :test_name
    has_many :variations
    belongs_to :label
  end
end
