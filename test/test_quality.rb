#!/usr/bin/env ruby -w
libdir = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "test/unit"

class TestQuality < Test::Unit::TestCase
  def test_can_still_be_built
    Dir.chdir(root) do
      `gem build rets4r.gemspec`
      assert_equal 0, $?
    end
  end

  def test_has_no_malformed_whitespace
    error_messages = []
    Dir.chdir(root) do
      File.read("MANIFEST").split("\n").each do |filename|
        error_messages << check_for_tab_characters(filename)
        error_messages << check_for_extra_spaces(filename)
      end
    end
    assert_well_formed error_messages.compact
  end

  def assert_well_formed(actual)
    assert actual.empty?, actual.join("\n")
  end

  def check_for_tab_characters(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line,number|
      failing_lines << number + 1 if line =~ /\t/
    end

    unless failing_lines.empty?
      "#{filename} has tab characters on lines #{failing_lines.join(', ')}"
    end
  end

  def check_for_extra_spaces(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line,number|
      next if line =~ /^\s+#.*\s+\n$/
      failing_lines << number + 1 if line =~ /\s+\n$/
    end

    unless failing_lines.empty?
      "#{filename} has spaces on the EOL on lines #{failing_lines.join(', ')}"
    end
  end

  def root
    File.expand_path("../..", __FILE__)
  end
end