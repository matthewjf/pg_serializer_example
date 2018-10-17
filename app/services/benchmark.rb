require 'benchmark'

class SerializerBenchmark
  def perform(n = 100)
    res = Benchmark.bmbm do |x|
      x.report("jbuilder") { n.times { app.get "http://localhost/api/products/jbuilder" } }
      x.report("fast_jsonapi") { n.times { app.get "http://localhost/api/products/fast_jsonapi" } }
      x.report("pg_serializable")  {  n.times { app.get "http://localhost/api/products/pg_serializable" } }
    end
    puts res
  end

  def app
    @app ||= ActionDispatch::Integration::Session.new(Rails.application)
  end
end
