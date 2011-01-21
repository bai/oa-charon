module OmniAuth
  module Strategies
    class Remote
      class Configuration
        DEFAULT_LOGIN_URL = "%s/login"
        DEFAULT_SERVICE_VALIDATE_URL = "%s/serviceValidate"

        # @param [Hash] params configuration options
        # @option params [String, nil] :server the server root URL; probably something like
        #         `http://auth.mycompany.com` or `http://mycompany.com/auth`; optional.
        # @option params [String, nil] :login_url (:server + '/login') the URL to which to
        #         redirect for logins; options if `:server` is specified,
        #         required otherwise.
        # @option params [String, nil] :service_validate_url (:server + '/serviceValidate') the
        #         URL to use for validating service tickets; optional if `:server` is
        #         specified, requred otherwise.
        def initialize(params)
          parse_params params
        end

        # Build a login URL from +service+.
        #
        # @param [String] service the service (a.k.a. return-to) URL
        # 
        # @return [String] a URL like `http://auth.mycompany.com/login?service=...`
        def login_url(service)
          append_service @login_url, service
        end

        # Build a service-validation URL from +service+ and +ticket+.
        #
        # @param [String] service the service (a.k.a. return-to) URL
        # @param [String] ticket the ticket to validate
        #
        # @return [String] a URL like `http://auth.mycompany.com/serviceValidate?service=...&ticket=...`
        def service_validate_url(service, ticket)
          url = append_service @service_validate_url, service
          url << '&ticket=' << Rack::Utils.escape(ticket)
        end

        private
          def parse_params(params)
            if params[:server].nil? && params[:login_url].nil?
              raise ArgumentError.new(":server or :login_url MUST be provided")
            end
            @login_url   = params[:login_url]
            @login_url ||= DEFAULT_LOGIN_URL % params[:server]
            validate_is_url 'login URL', @login_url

            if params[:server].nil? && params[:service_validate_url].nil?
              raise ArgumentError.new(":server or :service_validate_url MUST be provided")
            end
            @service_validate_url   = params[:service_validate_url]
            @service_validate_url ||= DEFAULT_SERVICE_VALIDATE_URL % params[:server]
            validate_is_url 'service-validate URL', @service_validate_url
          end

          IS_NOT_URL_ERROR_MESSAGE = "%s is not a valid URL"

          def validate_is_url(name, possibly_a_url)
            url = URI.parse(possibly_a_url) rescue nil
            raise ArgumentError.new(IS_NOT_URL_ERROR_MESSAGE % name) unless url.kind_of?(URI::HTTP)
          end

          # Adds +service+ as an URL-escaped parameter to +base+.
          #
          # @param [String] base the base URL
          # @param [String] service the service (a.k.a. return-to) URL.
          #
          # @return [String] the new joined URL.
          def append_service(base, service)
            result = base.dup
            result << (result.include?('?') ? '&' : '?')
            result << 'service='
            result << Rack::Utils.escape(service)
          end
      end
    end
  end
end
