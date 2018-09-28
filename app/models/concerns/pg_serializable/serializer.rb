module PgSerializable
  class Serializer
    attr_reader :klass
    attr_accessor :aliaser

    def initialize(klass)
      @klass = klass
      @attr_map = {}
      @assoc_map = {}
      @aliaser = PgSerializable::Aliaser.new
    end

    def attributes(*attrs)
      attrs.each do |atr|
        column_name = atr.to_s
        column_exists?(column_name)
        @attr_map["\'#{column_name}\'"] = column_name
      end
    end

    def attribute(column_name, label: nil)
      column_exists?(column_name)
      @attr_map["\'#{(label || column_name).to_s}\'"] = column_name.to_s
    end

    def has_many(association, label: nil)
      @assoc_map["\'#{(label || association).to_s}\'"] = association
    end

    def belongs_to
      # outside SELECT join
    end

    def has_one
    end

    def build_sql(scope, aliaser=nil)
      klass
        .unscoped
        .select(json_agg)
        .from(as(scope.to_sql, table_alias))
    end

    def as(sql, al)
      "(#{sql}) #{al}"
    end

    # private

    def build_attributes
      (build_simple_attributes + build_associations).flatten.join(',')
    end

    def build_simple_attributes
      @attr_map.map { |k,v| [k, "#{table_alias}.#{v}"] }
    end

    def build_associations
      @assoc_map.map do |k,v|
        next_alias = aliaser.next
        target = association(v)
        target_klass = target.klass
        foreign_key = target.join_keys.foreign_key
        key = target.join_keys.key
        target_klass.pg_serializer.aliaser = next_alias
        skope = target_klass.select(target_klass.pg_serializer.json_agg).from("#{target_klass.table_name} #{next_alias.name}").where("#{next_alias.name}.#{key}=#{table_alias}.#{foreign_key}")
        [k, "(#{skope.to_sql})"]
      end
    end

    def json_build_object
      "json_build_object(#{build_attributes})"
    end

    def json_agg
      "COALESCE(json_agg(#{json_build_object}), '[]'::json)"
    end

    def table_alias
      aliaser.name
    end

    def association(name)
      klass.reflect_on_association(name)
    end

    def column_exists?(column_name)
      raise AttributeError.new("#{column_name.to_s} column doesn't exist for table #{klass.table_name}") unless klass.column_names.include? column_name.to_s
    end


  end
end
