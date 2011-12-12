module RETS4R
  class Client
    # These are the response messages as defined in the RETS 1.5e2 and 1.7d6 specifications.
    # Provided for convenience and are used by the HTTPError class to provide more useful
    # messages.
    RETS_HTTP_MESSAGES = {
      '200' => 'Operation successful.',
      '400' => 'The request could not be understood by the server due to malformed syntax.',
      '401' => 'Either the header did not contain an acceptable Authorization or the ' +
               'username/password was invalid. The server response MUST include a ' +
               'WWW-Authenticate header field.',
      '402' => 'The requested transaction requires a payment which could not be authorized.',
      '403' => 'The server understood the request, but is refusing to fulfill it.',
      '404' => 'The server has not found anything matching the Request-URI.',
      '405' => 'The method specified in the Request-Line is not allowed for the resource ' +
               'identified by the Request-URI.',
      '406' => 'The resource identified by the request is only capable of generating response ' +
               'entities which have content characteristics not acceptable according to the accept ' +
               'headers sent in the request.',
      '408' => 'The client did not produce a request within the time that the server was prepared to wait.',
      '411' => 'The server refuses to accept the request without a defined Content-Length.',
      '412' => 'Transaction not permitted at this point in the session.',
      '413' => 'The server is refusing to process a request because the request entity is larger than ' +
               'the server is willing or able to process.',
      '414' => 'The server is refusing to service the request because the Request-URI is longer than ' +
               'the server is willing to interpret. This error usually only occurs for a GET method.',
      '500' => 'The server encountered an unexpected condition which prevented it from fulfilling ' +
               'the request.',
      '501' => 'The server does not support the functionality required to fulfill the request.',
      '503' => 'The server is currently unable to handle the request due to a temporary overloading ' +
               'or maintenance of the server.',
      '505' => 'The server does not support, or refuses to support, the HTTP protocol version that ' +
               'was used in the request message.',
    }

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
