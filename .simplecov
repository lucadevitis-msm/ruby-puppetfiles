SimpleCov.minimum_coverage 100
SimpleCov.minimum_coverage_by_file 100
SimpleCov.refuse_coverage_drop
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  add_filter '/spec/'
  # Exclude bundled Gems in `/.vendor/`
  add_filter '/.vendor/'
end
SimpleCov.at_exit do
    SimpleCov.result.format!
end

