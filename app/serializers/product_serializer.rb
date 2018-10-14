class ProductSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :id
  has_many :variations
  belongs_to :label
  has_many :categories
end
