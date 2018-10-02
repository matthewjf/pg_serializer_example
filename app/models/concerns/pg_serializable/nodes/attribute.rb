module PgSerializable
  module Nodes
    class Attribute
      def initialize(column_name, label: nil)
        @column_name = column_name
        @label = label || column_name
      end

      def to_sql
        ["\'#{@label}\'", @column_name].join(',')
      end

      def to_s
        to_sql
      end
    end
  end
end
