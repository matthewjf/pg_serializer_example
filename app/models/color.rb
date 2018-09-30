class Color < ApplicationRecord
  pg_serializable do
    attributes :id, :hex
  end
end
