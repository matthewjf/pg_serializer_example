module PgSerializable
  module Nodes
    class Association
      def initialize(klass, name, type, label: nil)
        @name = name
        @klass = klass
        @type = type
        @label = label || name
      end

      def to_sql(outer_alias, aliaser)
        ["\'#{@label}\'", "(#{value(outer_alias, aliaser)})"].join(',')
      end

      private

      def value(outer_alias, aliaser)
        next_alias = aliaser.next!
        case @type
        when :has_one
          target.as_json_array(aliaser).where("#{next_alias}.#{primary_key}=#{outer_alias}.#{foreign_key}").to_sql
        when :has_many
          target.as_json_object(aliaser).where("#{next_alias}.#{primary_key}=#{outer_alias}.#{foreign_key}").to_sql
        when :belongs_to
          subquery_alias = "#{next_alias[0].next}#{next_alias[1]}"
          target.select("DISTINCT ON (#{primary_key}) #{subquery_alias}.*").from(
            "#{target.table_name} #{subquery_alias}"
          ).as_json_object(aliaser).where("#{next_alias}.#{primary_key}=#{outer_alias}.#{foreign_key}").to_sql
        end
      end

      def association
        @association ||= @klass.reflect_on_association(@name)
      end

      def target
        @target ||= association.klass
      end

      def foreign_key
        @foreign_key ||= association.join_foreign_key
      end

      def primary_key
        @primary_key ||= association.join_primary_key
      end
    end
  end
end
