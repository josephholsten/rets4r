require 'shoulda'

class MatchAttributesMatcher
  attr_accessor :attrs, :expectation_block, :expected, :context, :shared_attributes, :subject
  def initialize(*attrs) #:yields: expected
    self.attrs = Array(attrs)
  end

  def matches?(subject)
    self.subject = subject
    self.shared_attributes = self.attrs.select {|a| self.expected_value.send(a) == subject.send(a) }
    self.shared_attributes == self.attrs
  end

  def failure_message
   "expected to match attributes #{attrs.join(', ')} of #{expected_value} " +
   "but #{(different).join(', ')} were different"
  end

  def negative_failure_message
   "expected not to match attributes #{attrs.join(', ')} of #{expected_value} " +
   "but #{(shared_attributes).join(', ')} were shared"
  end

  def description
    "to match attributes #{attrs.join(', ')} of #{expected_value}"
  end


  def in_context(context)
    self.context = context
    self
  end


  def of(expected_value = nil, &block)
    @expected_value = expected_value
    self.expectation_block = block
    self
  end

  def expected_value
    @expected_value = self.context.instance_eval(&self.expectation_block) if self.expectation_block
    @expected_value
  end

  def different
    attrs - shared_attributes
  end
end

def match_attributes(*attrs, &expected)
  MatchAttributesMatcher.new(*attrs, &expected)
end

def should_match_attributes(*attrs, &block)
  matcher = match_attributes(*attrs, &block)
  should matcher.description do
    assert_accepts matcher
  end
end
