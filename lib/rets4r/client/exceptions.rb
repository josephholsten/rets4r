module RETS4R
  class Client
    # This exception should be thrown when a generic client error is encountered.
    class ClientException < Exception; end
    
    # This exception should be thrown when there is an error with the parser, which is
    # considered a subcomponent of the RETS client. It also includes the XML data that
    # that was being processed at the time of the exception.
    class ParserException < ClientException
      attr_accessor :file
    end

    # The client does not currently support a specified action.
    class Unsupported < ClientException; end

    # The HTTP response returned by the server indicates that there was an error processing
    # the request and the client cannot continue on its own without intervention.
    class HTTPError < ClientException
      attr_accessor :http_response

      # Takes a HTTPResponse object
      def initialize(http_response)
        self.http_response = http_response
      end

      # Shorthand for calling HTTPResponse#code
      def code
        http_response.code
      end

      # Shorthand for calling HTTPResponse#message
      def message
        http_response.message
      end

      # Returns the RETS specification message for the HTTP response code
      def rets_message
        Client::RETS_HTTP_MESSAGES[code]
      end

      def to_s
        "#{code} #{message}: #{rets_message}"
      end
    end

    # A general RETS level exception was encountered. This would include HTTP and RETS
    # specification level errors as well as informative mishaps such as authentication being
    # required for access.
    class RETSException < RuntimeError; end

    # There was a problem with logging into the RETS server.
    class LoginError < RETSException; end

    # For internal client use only, it is thrown when the a RETS request is made but a password
    # is prompted for.
    class AuthRequired < RETSException; end

    # A RETS transaction failed
    class RETSTransactionException < RETSException; end

    # Search Transaction Exceptions
    class UnknownQueryFieldException < RETSTransactionException; end
    class NoRecordsFoundException < RETSTransactionException; end
    class InvalidSelectException < RETSTransactionException; end
    class MiscellaneousSearchErrorException < RETSTransactionException; end
    class InvalidQuerySyntaxException < RETSTransactionException; end
    class UnauthorizedQueryException < RETSTransactionException; end
    class MaximumRecordsExceededException < RETSTransactionException; end
    class TimeoutException < RETSTransactionException; end
    class TooManyOutstandingQueriesException < RETSTransactionException; end
    class DTDVersionUnavailableException < RETSTransactionException; end

    # GetObject Exceptions
    class InvalidResourceException < RETSTransactionException; end
    class InvalidTypeException < RETSTransactionException; end
    class InvalidIdentifierException < RETSTransactionException; end
    class NoObjectFoundException < RETSTransactionException; end
    class UnsupportedMIMETypeException < RETSTransactionException; end
    class UnauthorizedRetrievalException < RETSTransactionException; end
    class ResourceUnavailableException < RETSTransactionException; end
    class ObjectUnavailableException < RETSTransactionException; end
    class RequestTooLargeException < RETSTransactionException; end
    class TimeoutException < RETSTransactionException; end
    class TooManyOutstandingRequestsException < RETSTransactionException; end
    class MiscellaneousErrorException < RETSTransactionException; end
    
    EXCEPTION_TYPES = {
      # Search Transaction Reply Codes
      20200 => UnknownQueryFieldException,
      20201 => NoRecordsFoundException,
      20202 => InvalidSelectException,
      20203 => MiscellaneousSearchErrorException,
      20206 => InvalidQuerySyntaxException,
      20207 => UnauthorizedQueryException,
      20208 => MaximumRecordsExceededException,
      20209 => TimeoutException,
      20210 => TooManyOutstandingQueriesException,
      20514 => DTDVersionUnavailableException,

      # GetObject Reply Codes
      20400 => InvalidResourceException,
      20401 => InvalidTypeException,
      20402 => InvalidIdentifierException,
      20403 => NoObjectFoundException,
      20406 => UnsupportedMIMETypeException,
      20407 => UnauthorizedRetrievalException,
      20408 => ResourceUnavailableException,
      20409 => ObjectUnavailableException,
      20410 => RequestTooLargeException,
      20411 => TimeoutException,
      20412 => TooManyOutstandingRequestsException,
      20413 => MiscellaneousErrorException

    }
  end
end