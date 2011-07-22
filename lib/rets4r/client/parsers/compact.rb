#--
# Please, don't use this code.

module RETS4R #:nodoc:
  class Client #:nodoc:
    class CompactDataParser #:nodoc:
      def parse_results(doc) #:nodoc:
        warn "#{caller.first}: warning: #{self.class}#parse_results is deprecated and will be removed by rets4r 2.0; use RETS4R::ResponseDocument::Search#to_transaction instead"
        doc.to_a
      end

      def parse_data(column_element, row_elements, delimiter = "\t") #:nodoc:
        warn "#{caller.first}: warning: #{self.class}#parse_data is deprecated and will be removed by rets4r 2.0; use RETS4R::ResponseDocument::Search#to_transaction instead"
        headers = RETS4R::ResponseDocument::Search.split_raw_headers(column_element, delimiter)
        row_elements.map {|row| RETS4R::ResponseDocument::Search.row_to_hash(row.text, headers, delimiter) }
      end
    end
  end
end
