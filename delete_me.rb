# variation belongs_to product
JSON.parse(ActiveRecord::Base.connection.execute(<<-SQL
  SELECT json_agg(json_build_object(
    'id', a1.id,
    'name', a1.name,
    'product', json_build_object(
      'id', a2.id,
      'name', a2.name
    )
  )) json
  FROM (
    SELECT *
    FROM variations
  ) a1
  LEFT JOIN products a2
  ON a2.id=a1.product_id
SQL
).as_json.first['json'])

# product has_many variations
scoper = Product.select(
  <<-SQL
    COALESCE(json_agg(json_build_object(
      'id', z0.id,
      'name', z0.name,
      'variations', (
        SELECT
          COALESCE(
            json_agg(json_build_object(
              'id', z1.id,
              'name', z1.name
            )),
            '[]'::json
          )
        FROM variations z1
        WHERE z1.product_id=z0.id
      )
    )), '[]'::json)
  SQL
).from(Product.limit(3).as('z0'))

JSON.parse(ActiveRecord::Base.connection.select_one(scoper.to_sql).as_json['coalesce'])
<<-SQL
  SELECT COALESCE(json_agg(json_build_object(
    'name',z0.name,
    'id',z0.id,
    'test_name',z0.name,
    'variations',(
      SELECT COALESCE(json_agg(json_build_object(
        'name',z1.name,
        'id',z1.id)
      ), '[]'::json)
      FROM variations z1
      WHERE (z1.product_id=z0.id)
    ))
  ), '[]'::json)
  FROM (
    SELECT  "products".* FROM "products" LIMIT 3
  ) z0
  LIMIT 3)
SQL
