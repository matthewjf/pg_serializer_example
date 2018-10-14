class ColorSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :hex
end
