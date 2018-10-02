class Color < ApplicationRecord
  serializable do
    attributes :id, :hex
  end
end
