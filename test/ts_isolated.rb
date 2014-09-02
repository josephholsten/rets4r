$:.unshift File.expand_path('../../../lib',__FILE__)

require 'minitest/autorun'
require 'rbconfig'

class TestIsolated < Minitest::Test
  ruby = File.join(*RbConfig::CONFIG.values_at('bindir', 'RUBY_INSTALL_NAME'))

  Dir["#{File.dirname(__FILE__)}/**/test_*.rb"].each do |file|
    define_method("test #{file}") do
      command = "#{ruby} -Ilib:test #{file}"
      result = silence_stream(STDERR) { `#{command}` }
      assert_block("#{command}\n#{result}") { $?.to_i.zero? }
    end
  end
  unless defined? silence_stream
    def silence_stream(stream)
      old_stream = stream.dup
      stream.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
    end
  end
end
