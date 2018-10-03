json.extract! product, :id, :name
json.test_name product.name

json.variations product.variations, partial: 'api/variations/variation', as: :variation
json.label product.label, partial: 'api/labels/label', as: :label
json.categories product.categories, partial: 'api/categories/category', as: :category
