module PgSerializable
  class Serializer
    attr_reader :klass
    attr_reader :joins

    def initialize(klass)
      @klass = klass
      @attr_map = {}
      @assoc_map = {
        has_many: {},
        belongs_to: {},
        has_one: {}
      }
      @joins = []
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
      @assoc_map[:has_many]["\'#{(label || association).to_s}\'"] = association
    end

    def belongs_to(association, label: nil)
      @assoc_map[:belongs_to]["\'#{(label || association).to_s}\'"] = association
    end

    def has_one(association, label: nil)
      @assoc_map[:has_one]["\'#{(label || association).to_s}\'"] = association
    end

    def build_sql(scope, table_alias=nil)
      table_alias ||= Aliaser.next!
      query = klass
        .unscoped
        .select(json_agg(table_alias))
        .from(as(scope.to_sql, table_alias))

      @joins.inject(query) do |query, join|
        query.joins(join)
      end
    end

    def as(sql, table_alias)
      "(#{sql}) #{table_alias}"
    end

    # private

    def build_attributes(table_alias)
      (build_simple_attributes(table_alias) + build_associations(table_alias)).flatten.join(',')
    end

    def build_simple_attributes(table_alias)
      @attr_map.map { |k,v| [k, "#{table_alias}.#{v}"] }
    end

    def build_associations(table_alias)
      @joins = []
      @next_alias = Aliaser.next!(table_alias)

      @assoc_map[:has_many].map do |k,v|
        na = @next_alias
        @next_alias = Aliaser.next!(@next_alias)
        target = association(v)
        target_klass = target.klass
        foreign_key = target.join_foreign_key
        key = target.join_primary_key
        skope = target_klass.build_sql(na).where("#{na}.#{key}=#{table_alias}.#{foreign_key}")
        [k, "(#{skope.to_sql})"]
      end +
      @assoc_map[:belongs_to].map do |k,v|
        na = @next_alias
        @next_alias = Aliaser.next!(@next_alias)
        target = association(v)
        target_klass = target.klass
        foreign_key = target.join_foreign_key
        key = target.join_primary_key
        @joins << "LEFT JOIN #{target_klass.table_name} #{na} ON #{table_alias}.#{foreign_key}=#{na}.#{key}"
        build_object_result = target_klass.pg_serializer.json_build_object(na)
        @joins += target_klass.pg_serializer.joins # pull joins from target class to outer scope
        [k, "CASE WHEN #{na}.#{key} IS NOT NULL THEN #{build_object_result} ELSE NULL END"]
      end +
      @assoc_map[:has_one].map do |k,v|
        na = @next_alias
        @next_alias = Aliaser.next!(@next_alias)
        target = association(v)
        target_klass = target.klass
        foreign_key = target.join_foreign_key
        key = target.join_primary_key
        @joins << "LEFT JOIN #{target_klass.table_name} #{na} ON #{table_alias}.#{foreign_key}=#{na}.#{key}"
        build_object_result = target_klass.pg_serializer.json_build_object(na)
        @joins += target_klass.pg_serializer.joins # pull joins from target klass to outer scope
        [k, "CASE WHEN #{na}.#{key} IS NOT NULL THEN #{build_object_result} ELSE NULL END"]
      end
    end

    def json_build_object(table_alias)
      "json_build_object(#{build_attributes(table_alias)})"
    end

    def json_agg(table_alias)
      "COALESCE(json_agg(#{json_build_object(table_alias)}), '[]'::json)"
    end

    def association(name)
      klass.reflect_on_association(name)
    end

    def column_exists?(column_name)
      raise AttributeError.new("#{column_name.to_s} column doesn't exist for table #{klass.table_name}") unless klass.column_names.include? column_name.to_s
    end
  end
end
