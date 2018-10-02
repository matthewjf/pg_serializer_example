module PgSerializable
  class Serializer
    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @attributes = []
    end

    def attributes(*attrs)
      attrs.each do |attribute|
        @attributes << Attributes::Simple.new(attribute)
      end
    end

    def attribute(column_name, label: nil)
      @attributes << Attributes::Simple.new(column_name, label: label)
    end

    def has_many(association, label: nil)
      @attributes << Attributes::Association.new(klass, association, :has_many, label: label)
    end

    def belongs_to(association, label: nil)
      @attributes << Attributes::Association.new(klass, association, :belongs_to, label: label)
    end

    def has_one(association, label: nil)
      @attributes << Attributes::Association.new(klass, association, :has_one, label: label)
    end

    def as_json_array(scope, aliaser=nil)
      @aliaser = aliaser || Aliaser.new
      table_alias

      query = klass
        .unscoped
        .select(json_agg)
        .from(as(scope.to_sql, table_alias))
    end

    def as_json_object(scope, aliaser=nil)
      @aliaser = aliaser || Aliaser.new
      table_alias

      query = klass
        .unscoped
        .select(json_build_object)
        .from(as(scope.to_sql, table_alias))
    end

    def as(sql, table_alias)
      "(#{sql}) #{table_alias}"
    end

    # private

    def build_attributes
      res = []
      @attributes.each do |attribute|
        if attribute.is_a?(Attributes::Simple)
          res << attribute.to_sql
        elsif attribute.is_a?(Attributes::Association)
          res << attribute.to_sql(table_alias, @aliaser)
        else
          raise 'unknown attribute type'
        end
      end
      res.join(',')
    end

    def json_build_object
      "json_build_object(#{build_attributes})"
    end

    def json_agg
      "COALESCE(json_agg(#{json_build_object}), '[]'::json)"
    end

    def table_alias
      @table_alias ||= @aliaser.to_s
    end

    def association(name)
      klass.reflect_on_association(name)
    end

    def column_exists?(column_name)
      raise AttributeError.new("#{column_name.to_s} column doesn't exist for table #{klass.table_alias}") unless klass.column_names.include? column_name.to_s
    end
  end
end
