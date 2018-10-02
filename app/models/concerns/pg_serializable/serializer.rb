module PgSerializable
  class Serializer
    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @attributes = []
    end

    def attributes(*attrs)
      attrs.each do |attribute|
        @attributes << Nodes::Attribute.new(attribute)
      end
    end

    def attribute(column_name, label: nil)
      @attributes << Nodes::Attribute.new(column_name, label: label)
    end

    def has_many(association, label: nil)
      @attributes << Nodes::Association.new(klass, association, :has_many, label: label)
    end

    def belongs_to(association, label: nil)
      @attributes << Nodes::Association.new(klass, association, :belongs_to, label: label)
    end

    def has_one(association, label: nil)
      @attributes << Nodes::Association.new(klass, association, :has_one, label: label)
    end

    def as_json_array(scope, aliaser)
      @aliaser = aliaser
      @table_alias = aliaser.to_s

      query = klass
        .unscoped
        .select(json_agg.to_sql)
        .from(Nodes::As.new(scope, table_alias).to_sql)
    end

    def as_json_object(scope, aliaser)
      @aliaser = aliaser
      @table_alias = aliaser.to_s

      query = klass
        .unscoped
        .select(json_build_object.to_sql)
        .from(Nodes::As.new(scope, table_alias).to_sql)
    end

    # private

    def build_attributes
      res = []
      @attributes.each do |attribute|
        if attribute.is_a?(Nodes::Attribute)
          res << attribute.to_sql
        elsif attribute.is_a?(Nodes::Association)
          res << attribute.to_sql(table_alias, @aliaser)
        else
          raise 'unknown attribute type'
        end
      end
      res.join(',')
    end

    def json_build_object
      Nodes::JsonBuildObject.new(build_attributes)
    end

    def json_agg
      Nodes::Coalesce.new(Nodes::JsonAgg.new(json_build_object), Nodes::JsonArray.new)
    end

    def table_alias
      @table_alias
    end

    def association(name)
      klass.reflect_on_association(name)
    end

    def column_exists?(column_name)
      raise AttributeError.new("#{column_name.to_s} column doesn't exist for table #{klass.table_alias}") unless klass.column_names.include? column_name.to_s
    end
  end
end
