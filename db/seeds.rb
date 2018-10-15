require 'ffaker'

50.times do |i|
  Label.create(name: FFaker::Name.first_name)
end

100.times do |i|
  Category.create(name: FFaker::Name.first_name)
end

200.times do |i|
  Color.create(hex: FFaker::Color.hex_code)
end
PRODUCT_TYPES = Product.defined_enums['product_type'].keys
500.times do |i|
  product = Product.create(name: FFaker::Product.product_name, label: Label.order("RANDOM()").first, product_type: PRODUCT_TYPES.sample)
  product.categories = Category.order("RANDOM()").limit(rand(5))
  product.variations = rand(10).times.map do
    Variation.create(color: Color.order("RANDOM()").first, name: FFaker::Name.last_name)
  end
end
