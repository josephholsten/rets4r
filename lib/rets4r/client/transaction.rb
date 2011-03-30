require 'forwardable'
module RETS4R
  class Client
    class Transaction
      extend Forwardable

      attr_accessor :response, :metadata,
        :header, :delimiter, :secondary_response, :doc

      def initialize(doc = nil)
        self.doc = doc || ResponseDocument::Base.new
        self.header = []
        self.delimiter = ?\t
      end

      def_delegators :doc, :max_rows?, :reply_text, :success?

      def reply_code
        if $VERBOSE
          warn("#{caller.first}: warning: as of rets4r 2.0 #{self.class}#reply_code will be a numeric")
        end
        doc.reply_code.to_s
      end

      def ascii_delimiter
        self.delimiter.chr
      end

      class << self
          def deprecated_alias(old, new, msg = nil) # :nodoc:
            msg ||= "use \#{self.class}\##{new}"
            module_eval <<-"end;"
              def #{old}(*args, &block)
                if $VERBOSE
                  warn("\#{caller.first}: " \
                 "warning: \#{self.class}\##{old} is deprecated; #{msg}")
                end
                #{new}(*args, &block)
              end
            end;
          end
          private :deprecated_alias

          def deprecated_attr_reader(*attrs) # :nodoc:
            attrs.each do |old|
              module_eval <<-"end;"
                def #{old}=(obj)
                  if $VERBOSE
                    warn("\#{caller.first}: " \
                   "warning: \#{self.class}\##{old} is deprecated; \#{self.class}\##{old} is now set at initialization")
                  end
                  @#{old} = obj
                end
              end;
            end
          end
          private :deprecated_attr_reader
      end

      # For compatibility with the original library.
      deprecated_alias :data, :response
      deprecated_alias :maxrows?, :max_rows?
      deprecated_alias :maxrows, :max_rows?

      deprecated_attr_reader :maxrows, :reply_text, :reply_code

    end
  end
end
