require 'active_support/concern'

module PgSerializable
  extend ActiveSupport::Concern
  included do
  end

  class_methods do
    def as_array
      ActiveRecord::Base.connection.select_one(
        serializer.as_json_array(pg_scope, Aliaser.new).to_sql
      ).as_json['coalesce']
    end

    def as_json_array(table_alias = Aliaser.new)
      serializer.as_json_array(pg_scope, table_alias)
    end

    def as_json_object(table_alias = Aliaser.new)
      serializer.as_json_object(pg_scope, table_alias)
    end

    def pg_serializable(&blk)
      serializer.instance_eval &blk
    end

    def serializer
      @serializer ||= Serializer.new(self)
    end

    def pg_scope
      respond_to?(:to_sql) ? self : all
    end
  end
end
