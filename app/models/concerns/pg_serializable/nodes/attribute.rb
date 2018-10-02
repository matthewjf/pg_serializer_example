module PgSerializable
  module Nodes
    class Attribute < Base
      def initialize(column_name, label: nil)
        @column_name = column_name
        @label = label || column_name
      end

      def to_sql
        ["\'#{@label}\'", @column_name].join(',')
      end
    end
  end
end
