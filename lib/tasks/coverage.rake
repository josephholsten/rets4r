begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = "test/test_*.rb"
    test.verbose = true
    test.rcov_opts << ' --sort coverage'
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: gem install rcov"
  end
end
