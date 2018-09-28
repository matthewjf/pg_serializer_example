require 'active_support/concern'

class ModelSerializer
  attr_reader :model

  def initialize(klass)
    @model = klass
  end

  def attributes(attrs)
  end

  def attribute(label, column_name)
  end

  def has_many
  end

  def has_one
  end

  def belongs_to
  end
end

module PgSerializable
  extend ActiveSupport::Concern
  included do
    def as_json_object
    end
  end

  class_methods do
    def model_serializer
      @model_serializer ||= ModelSerializer.new(self)
    end

    def pg_serializable(&blk)

    end

    def as_json_array
      target = respond_to?(:to_sql) ? self : all
      JSON.parse(
        ActiveRecord::Base.connection.execute(
          "SELECT json_agg(a.*) AS json FROM (#{target.to_sql}) a"
        ).as_json.first['json']
      )
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
