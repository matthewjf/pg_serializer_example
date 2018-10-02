require 'active_support/concern'

module PgSerializable
  extend ActiveSupport::Concern
  included do
  end

  class_methods do
    def as_array
      ActiveRecord::Base.connection.select_one(
        pg_serializer.as_json_array(pg_scope).to_sql
      ).as_json['coalesce']
    end

    def as_json_array(table_alias = nil)
      pg_serializer.as_json_array(pg_scope, table_alias)
    end

    def as_json_object(table_alias = nil)
      pg_serializer.as_json_object(pg_scope, table_alias)
    end

    def pg_serializable(&blk)
      pg_serializer.instance_eval &blk
    end

    def pg_serializer
      @pg_serializer ||= Serializer.new(self)
    end

    def pg_scope
      respond_to?(:to_sql) ? self : all
    end
  end
end
