module PgSerializable
  class Serializer
    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @attr_map = {}
      @assoc_map = {
        has_many: {},
        belongs_to: {},
        has_one: {}
      }
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

    def as_json_array(scope, aliaser=nil)
      @aliaser = aliaser || Aliaser.new
      table_name

      query = klass
        .unscoped
        .select(json_agg)
        .from(as(scope.to_sql, table_name))
    end

    def as_json_object(scope, aliaser=nil)
      @aliaser = aliaser || Aliaser.new
      table_name

      query = klass
        .unscoped
        .select(json_build_object)
        .from(as(scope.to_sql, table_name))
    end

    def as(sql, table_name)
      "(#{sql}) #{table_name}"
    end

    # private

    def build_attributes
      (build_simple_attributes + build_associations).flatten.join(',')
    end

    def build_simple_attributes
      @attr_map.map { |k,v| [k, "#{table_name}.#{v}"] }
    end

    def build_associations
      @assoc_map[:has_many].map do |k,v|
        next_alias = @aliaser.next!
        target = association(v)
        target_klass = target.klass
        foreign_key = target.join_foreign_key
        key = target.join_primary_key
        skope = target_klass.as_json_array(@aliaser).where("#{next_alias}.#{key}=#{table_name}.#{foreign_key}")
        [k, "(#{skope.to_sql})"]
      end +
      @assoc_map[:belongs_to].map do |k,v|
        next_alias = @aliaser.next!
        target = association(v)
        target_klass = target.klass
        foreign_key = target.join_foreign_key
        key = target.join_primary_key
        skope = target_klass.as_json_object(@aliaser).where("#{next_alias}.#{key}=#{table_name}.#{foreign_key}")
        [k, "(#{skope.to_sql})"]
      end +
      @assoc_map[:has_one].map do |k,v|
        next_alias = @aliaser.next!
        subquery_alias = next_alias[0].next + next_alias[1]
        target = association(v)
        target_klass = target.klass
        foreign_key = target.join_foreign_key
        key = target.join_primary_key
        skope = target_klass.select("DISTINCT ON (#{key}) #{subquery_alias}.*").from(
          "#{target_klass.table_name} #{subquery_alias}"
        ).as_json_object(@aliaser).where("#{next_alias}.#{key}=#{table_name}.#{foreign_key}")
        [k, "(#{skope.to_sql})"]
      end
    end

    def json_build_object
      "json_build_object(#{build_attributes})"
    end

    def json_agg
      "COALESCE(json_agg(#{json_build_object}), '[]'::json)"
    end

    def table_name
      @table_name ||= @aliaser.to_s
    end

    def association(name)
      klass.reflect_on_association(name)
    end

    def column_exists?(column_name)
      raise AttributeError.new("#{column_name.to_s} column doesn't exist for table #{klass.table_name}") unless klass.column_names.include? column_name.to_s
    end
  end
end
