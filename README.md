# README

This is an example application that uses the [pg_serializable](https://github.com/matthewjf/pg_serializable) gem.

Also contains benchmarking code against
[jbuilder](https://github.com/rails/jbuilder) and [fast_jsonapi](https://github.com/Netflix/fast_jsonapi).

To run benchmarks:
```ruby
SerializerBenchmark.new.perform
```

You can also pass a number of iterations to run:
```ruby
SerializerBenchmark.new.perform(10)
```
