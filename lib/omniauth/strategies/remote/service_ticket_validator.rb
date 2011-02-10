require "yajl"
require "net/http"

module OmniAuth
  module Strategies
    class Remote
      class ServiceTicketValidator        
        VALIDATION_REQUEST_HEADERS = { "Accept" => "*/*" }

        # Build a validator from a +configuration+, a
        # +return_to+ URL, and a +ticket+.
        #
        # @param [OmniAuth::Strategies::Remote::Configuration] configuration server configuration
        # @param [String] service the name of this client service
        # @param [String] ticket the service ticket to validate
        def initialize(configuration, service, ticket)
          @uri = URI.parse(configuration.service_validate_url(service, ticket))
          @parser = Yajl::Parser.new
        end

        # Request validation of the ticket from the server's
        # serviceValidate function.
        #
        # Swallows all JSON parsing errors (and returns +nil+ in those cases).
        #
        # @return [Hash, nil] a user information hash if the response is valid; +nil+ otherwise.
        #
        # @raise any connection errors encountered.
        def user_info
          service_response_body = get_service_response_body

          return nil if service_response_body.nil? || service_response_body == ''
          
          @parser.parse(service_response_body)
        end

        private
          # Retrieves the `serviceResponse` JSON from the server.
          def get_service_response_body
            result = ''
            http = Net::HTTP.new(@uri.host, @uri.port)
            http.use_ssl = @uri.port == 443 || @uri.instance_of?(URI::HTTPS)
            http.start do |c|
              response = c.get "#{@uri.path}?#{@uri.query}", VALIDATION_REQUEST_HEADERS
              result = response.body
            end
            result
          end
      end
    end
  end
end
