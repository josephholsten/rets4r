#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

class TestQuality < Test::Unit::TestCase
  def test_can_still_be_built
    Dir.chdir(PROJECT_ROOT) do
      `gem build rets4r.gemspec`
      assert_equal 0, $?
    end
  end

  def test_has_no_malformed_whitespace
    error_messages = []
    Dir.chdir(PROJECT_ROOT) do
      File.read("MANIFEST").split("\n").each do |filename|
        if code_file?(filename)
          error_messages << check_for_tab_characters(filename)
          error_messages << check_for_extra_spaces(filename)
        end
      end
    end
    assert_well_formed error_messages.compact
  end

  def test_manifest_up_to_date
    Dir.chdir(PROJECT_ROOT) do
      files = `git ls-files`
      assert_equal File.read('MANIFEST'), files
    end
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

  def code_file?(filename)
    additional_files = %w(Rakefile Gemfile rake)
    filename =~ /.rb|.yml/ || additional_files.include?(filename)
  end
end
