class VariationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :id
  belongs_to :color
end
