# RETS4R Client
#
# Copyright (c) 2005 Scott Patterson <scott.patterson@digitalaun.com>
#
# This program is copyrighted free software by Scott Patterson.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003 (see the file RUBYS), or any later
# version.
#
#	TODO
#		1.0 Support (Adding this support should be fairly easy)
#		1.7 Support (Adding this support should be fairly easy)
#		2.0 Support (Adding this support will be very difficult since it is a completely different methodology)
#		Case-insensitive header

require 'digest/md5'
require 'net/http'
require 'uri'
require 'cgi'
require 'rets4r/auth'
require 'rets4r/client/dataobject'
require 'thread'
require 'logger'

module RETS4R
	class Client
		OUTPUT_RAW	= 0	# Nothing done. Simply returns the XML.
		OUTPUT_DOM	= 1	# Returns a DOM object (REXML)	**** NO LONGER SUPPORTED! ****
		OUTPUT_RUBY	= 2 # Returns a RETS::Data object
		
		METHOD_GET	= 'GET'
		METHOD_POST = 'POST'
		METHOD_HEAD = 'HEAD'
		
		DEFAULT_OUTPUT		   = OUTPUT_RUBY
		DEFAULT_METHOD 		   = METHOD_GET
		DEFAULT_RETRY        = 2
		DEFAULT_USER_AGENT 	 = 'RETS4R/0.8.1'
		DEFAULT_RETS_VERSION = '1.5'
		SUPPORTED_RETS_VERSIONS = ['1.5']
		CAPABILITY_LIST   = ['Action', 'ChangePassword', 'GetObject', 'Login', 'LoginComplete', 'Logout', 'Search', 'GetMetadata', 'Update']
		SUPPORTED_PARSERS = [] # This will be populated by parsers as they load

		attr_accessor :mimemap, :logger
		
		# We load our parsers here so that they can modify the client class appropriately. Because
		# the default parser will be the first parser to list itself in the DEFAULT_PARSER array,
		# we need to require them in the order of preference. Hence, XMLParser is loaded first because
		# it is preferred to REXML since it is much faster.
		require 'rets4r/client/parser/xmlparser'
		require 'rets4r/client/parser/rexml'
		
		# Set it as the first
		DEFAULT_PARSER = SUPPORTED_PARSERS[0]
		
		# Constructor
		# 
		# Requires the URL to the RETS server and takes an optional output format. The output format
		# determines the type of data returned by the various RETS transaction methods.
		def initialize(url, output = DEFAULT_OUTPUT)
			raise Unsupported.new('DOM output is no longer supported.') if output == OUTPUT_DOM
			
			@urls     = { 'Login' => URI.parse(url) }
			@nc       = 0
			@headers  = {
				'User-Agent'   => DEFAULT_USER_AGENT, 
				'Accept'       => '*/*', 
				'RETS-Version' => "RETS/#{DEFAULT_RETS_VERSION}", 
				'RETS-Session-ID' => '0'
				}
			@request_method = DEFAULT_METHOD
			@parser         = DEFAULT_PARSER
			@semaphore      = Mutex.new
			@output         = output
			
			self.mimemap		= {
				'image/jpeg'  => 'jpg',
				'image/gif'   => 'gif'
				}
				
			if block_given?
				yield self
			end
		end
		
		# We only allow external read access to URLs because they are internally set based on the
		# results of various queries.
		def urls
			@urls
		end
		
		# Parses the provided XML returns it in the specified output format.
		# Requires an XML string and takes an optional output format to override the instance output
		# format variable. We current create a new parser each time, which seems a bit wasteful, but
		# it allows for the parser to be changed in the middle of a session as well as XML::Parser
		# requiring a new instance for each execution...that could be encapsulated within its parser
		# class,though, so we should benchmark and see if it will make a big difference with the 
		# REXML parse, which I doubt.
		def parse(xml, output = false)
			if xml == ''
				trans = Transaction.new()
				trans.reply_code = -1
				trans.reply_text = 'No transaction body was returned!'
			end
			
			if output == OUTPUT_RAW || @output == OUTPUT_RAW
				xml
			else
				begin
					parser = @parser.new
					parser.logger = logger
					parser.output = output ? output : @output

					parser.parse(xml)
				rescue
					raise ParserException.new($!)
				end
			end
		end
		
		# Setup Methods (accessors and mutators)
		def set_output(output = DEFAULT_OUTPUT)
			@output = output
		end
		
		def get_output
			@output
		end
		
		def set_parser_class(klass, force = false)
			if force || SUPPORTED_PARSERS.include?(klass)
				@parser = klass
			else
				message = "The parser class '#{klass}' is not supported!"
				logger.debug(message) if logger
				
				raise Unsupported.new(message)
			end
		end
		
		def get_parser_class
			@parser.class
		end
		
		def set_header(name, value)
			@headers[name] = value
			
			logger.debug("Set header '#{name}' to '#{value}'") if logger
		end
		
		def get_header(name)
			@headers[name]
		end
		
		def set_user_agent(name)
			set_header('User-Agent', name)
		end
		
		def get_user_agent
			get_header('User-Agent')
		end
		
		def set_rets_version(version)
			if (SUPPORTED_RETS_VERSIONS.include? version)
				set_header('RETS-Version', version)
			else
				raise Unsupported.new("The client does not support RETS version '#{version}'.")
			end
		end
		
		def get_rets_version
			get_header('RETS-Version')
		end
		
		def set_request_method(method)
			@request_method = method
		end
		
		def get_request_method
			@request_method
		end
		
		#### RETS Transaction Methods ####
		#
		# Most of these transaction methods mirror the RETS specification methods, so if you are 
		# unsure what they mean, you should check the RETS specification. The latest version can be
		# found at http://www.rets.org
		
		# Attempts to log into the server using the provided username and password.
		def login(username, password)
			@username = username
			@password = password
			
			# We are required to set the Accept header to this by the RETS 1.5 specification.
			set_header('Accept', '*/*')
			
			response = request(@urls['Login'])
			
			# Parse response to get other URLS
			results = self.parse(response.body, OUTPUT_RUBY)
			
			if (results.success?)
				CAPABILITY_LIST.each do |capability|
					next unless results.response[capability]
					base = @urls['Login'].clone
					base.path = results.response[capability]
					
					@urls[capability] = base
				end
				
				logger.debug("Capability URL List: #{@urls.inspect}") if logger
			else
				raise LoginError.new(response.message + "(#{results.reply_code}: #{results.reply_text})")
			end
			
			if @output != OUTPUT_RUBY
				results = self.parse(response.body)
			end
			
			# Perform the mandatory get request on the action URL.
			results.secondary_response = perform_action_url
			
			# We only yield if 
			if block_given?
				yield results
				
				self.logout
			end
			
			return results
		end
		
		# Logs out of the RETS server.
		def logout()
			# If no logout URL is provided, then we assume that logout is not necessary (not to 
			# mention impossible without a URL). We don't throw an exception, though, but we might
			# want to if this becomes an issue in the future.
			
			request(@urls['Logout']) if @urls['Logout']
		end
		
		# Requests Metadata from the server. An optional type and id can be specified to request
		# subsets of the Metadata. Please see the RETS specification for more details on this.
		# The format variable tells the server which format to return the Metadata in. Unless you
		# need the raw metadata in a specified format, you really shouldn't specify the format.
		def get_metadata(type = 'METADATA-SYSTEM', id = '*', format = 'COMPACT')
			header = {
				'Accept' => 'text/xml,text/plain;q=0.5'
			}
			
			data = {
				'Type'   => type,
				'ID'     => id,
				'Format' => format
			}
					
			response = request(@urls['GetMetadata'], data, header)
			
			result = self.parse(response.body)
			
			if block_given?
				yield result
			end
			
			return result
		end
		
		# Performs a GetObject transaction on the server. For details on the arguments, please see
		# the RETS specification on GetObject requests.
		def get_object(resource, type, id, location = 1)
			header = {
				'Accept' => mimemap.keys.join(',')
			}
			
			data = {
				'Resource' => resource,
				'Type'     => type,
				'ID'       => id,
				'Location' => location.to_s
			}
			
			response = request(@urls['GetObject'], data, header)
			results  = nil
			
			if response['content-type'].include?('multipart/parallel')
				content_type = process_content_type(response['content-type'])

				objects = []

				parts = response.body.split("--#{content_type['boundary']}")
				parts.shift # Get rid of the initial boundary
				
				parts.each do |part|
					(raw_header, raw_data) = part.split("\r\n\r\n")
					
					next unless raw_data
					
					data_header = process_header(raw_header)
					
					extension = 'unknown'
					extension = self.mimemap[data_header['Content-Type']] if self.mimemap[data_header['Content-Type']]
					
					objects << DataObject.new(data_header, raw_data)
				end 
				
				results = objects
			else
				info = {
					'content-type' => response['content-type'],
					'Object-ID'    => response['Object-ID'],
					'Content-ID'   => response['Content-ID']
				}

				results = [DataObject.new(info, response.body)] if response['Content-Length'].to_i > 100
			end
			
			if block_given?
				yield results
			end
						
			return results
		end
		
		# Peforms a RETS search transaction. Again, please see the RETS specification for details
		# on what these parameters mean. The options parameter takes a hash of options that will
		# added to the search statement.
		def search(search_type, klass, query, options = false)
			header = {}
		
			# Required Data
			data = {
				'SearchType' => search_type,
				'Class'      => klass,
				'Query'      => query,
				'QueryType'  => 'DMQL2',
				'Format'     => 'COMPACT',
				'Count'      => '0'
			}
			
			# Options
			#--
			# We might want to switch this to merge!, but I've kept it like this for now because it
			# explicitly casts each value as a string prior to performing the search, so we find out now
			# if can't force a value into the string context. I suppose it doesn't really matter when
			# that happens, though...
			#++
			options.each { |k,v| data[k] = v.to_s } if options
			
			response = request(@urls['Search'], data, header)
			
			results = self.parse(response.body)
			
			if block_given?
				yield
			else
				return results
			end
		end
		
		private
	
		def process_content_type(text)
			content = {}
			
			field_start = text.index(';')

			# The -1 is to remove the semi-colon (";")
			content['content-type'] = text[0..(field_start - 1)].strip
			fields = text[field_start..-1]
			
			parts = text.split(';')
			
			parts.each do |part|
				(name, value) = part.split('=')
				
				content[name.strip] = value ? value.strip : value
			end
			
			content
		end
		
		# Processes the HTTP header
		#-- 
		# Could we switch over to using CGI for this?
		#++
		def process_header(raw)
			header = {}
			
			raw.each do |line|
				(name, value) = line.split(':')
				
				header[name.strip] = value.strip if name && value
			end
			
			header
		end
		
		# Given a hash, it returns a URL encoded query string.
		def create_query_string(hash)
			parts = hash.map {|key,value| "#{CGI.escape(key)}=#{CGI.escape(value)}"}
			return parts.join('&')
		end
		
		# This is the primary transaction method, which the other public methods make use of.
		# Given a url for the transaction (endpoint) it makes a request to the RETS server.
		# 
		#-- 
		# This needs to be better documented, but for now please see the public transaction methods
		# for how to make use of this method.
		#++
		def request(url, data = {}, header = {}, method = @request_method, retry_auth = DEFAULT_RETRY)
			response = ''
			
			@semaphore.lock
			
			set_header('RETS-Request-ID', Digest::MD5.hexdigest(Time.new.to_f.to_s))
			
			Net::HTTP.start(url.host, url.port) do |http|
				begin
					uri = url.path
					
					if ! data.empty? && method == METHOD_GET
						uri += "?#{create_query_string(data)}"
					end

					headers = @headers
					headers.merge(header) unless header.empty?
					
					logger.debug(headers.inspect) if logger
					
					@semaphore.unlock
										
					response = http.get(uri, headers)
										
					@semaphore.lock
					
					if response.code == '401'
						# Authentication is required
						raise AuthRequired
					else
						set_header('Cookie', response['set-cookie']) if response['set-cookie']
						set_header('RETS-Session-ID', response['RETS-Session-ID']) if response['RETS-Session-ID']
					end
				rescue AuthRequired
					@nc += 1

					if retry_auth > 0
						retry_auth -= 1
						set_header('Authorization', Auth.authenticate(response, @username, @password, url.path, method, @headers['RETS-Request-ID'], get_user_agent, @nc))
						retry
					end
				end		
				
				logger.debug(response.body) if logger
			end
			
			@semaphore.unlock if @semaphore.locked?
			
			return response
		end
		
		# If an action URL is present in the URL capability list, it calls that action URL and returns the
		# raw result. Throws a generic RETSException if it is unable to follow the URL.
		def perform_action_url
			begin
				if @urls.has_key?('Action')
					return request(@urls['Action'], {}, {}, METHOD_GET)
				end
			rescue
				raise RETSException.new("Unable to follow action URL: '#{$!}'.")
			end
		end
		
		#### Exceptions ####
		
		# This exception should be thrown when a generic client error is encountered.
		class ClientException < Exception
		end
		
		# This exception should be thrown when there is an error with the parser, which is 
		# considered a subcomponent of the RETS client. It also includes the XML data that
		# that was being processed at the time of the exception.
		class ParserException < ClientException
			attr_accessor :file
		end
		
		# The client does not currently support a specified action.
		class Unsupported < ClientException
		end
		
		# A general RETS level exception was encountered. This would include HTTP and RETS 
		# specification level errors as well as informative mishaps such as authentication being
		# required for access.
		class RETSException < Exception
		end
		
		# There was a problem with logging into the RETS server.
		class LoginError < RETSException
		end
		
		# For internal client use only, it is thrown when the a RETS request is made but a password
		# is prompted for.
		class AuthRequired < RETSException
		end
	end
end 
