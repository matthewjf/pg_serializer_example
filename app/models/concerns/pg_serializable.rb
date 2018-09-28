require 'active_support/concern'

module PgSerializable
  extend ActiveSupport::Concern
  included do
    def as_json_object
      raise
    end
  end

  class_methods do
    def as_json_array
      JSON.parse(
        ActiveRecord::Base.connection.select_one(
          pg_serializer.build_sql(pg_scope).to_sql
        ).as_json['coalesce']
      )
    end

    def build_sql(aliaser = nil)
      pg_serializer.build_sql(pg_scope, aliaser)
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

=begin
  class Product < ApplicationRecord
    pg_serializable do
      attributes :name
      attribute :test_name, :name
      has_many :categories, -> { joins(:categories) }
    end
  end

  Product.limit(10).as_json(:test)
  => {name: 'whatever', test_name: 'whatever', categories: [{name: 'yyy'}, {name: 'zzz'}] }
=end
