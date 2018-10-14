require 'benchmark'

class SerializerBenchmark
  def perform(n = 100)
    res = Benchmark.bmbm do |x|
      x.report("fast_jsonapi") { n.times { app.get "http://localhost/api/products/fast_jsonapi";1 } }
      x.report("pg_serializable")  {  n.times { app.get "http://localhost/api/products/pg_serializable";1 } }
    end
    puts res
  end

  def app
    @app ||= ActionDispatch::Integration::Session.new(Rails.application)
  end
end
