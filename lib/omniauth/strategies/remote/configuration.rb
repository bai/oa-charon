module OmniAuth
  module Strategies
    class Remote
      class Configuration
        SERVICE_LOGIN_URL = "%s/serviceLogin"
        SERVICE_VALIDATE_URL = "%s/serviceValidate"

        # @param [Hash] params configuration options
        # @option params [String, nil] :server the server root URL; probably something like
        #         `http://auth.mycompany.com` or `http://mycompany.com/auth`; optional.
        # @option params [String, nil] :service name of this service, i.e.
        #         `pipeline` or `partnerships`; optional.
        def initialize(params)
          parse_params params
        end

        # Build a login URL from +service+.
        #
        # @param [String] service the service (a.k.a. return-to) URL
        # 
        # @return [String] a URL like `http://auth.mycompany.com/serviceLogin?s=...`
        def login_url
          append_service @login_url
        end

        # Build a service-validation URL from +service+ and +ticket+.
        #
        # @param [String] service the service (a.k.a. return-to) URL
        # @param [String] ticket the ticket to validate
        #
        # @return [String] a URL like `http://auth.mycompany.com/serviceValidate?s=...&t=...`
        def service_validate_url(service, ticket)
          url = append_service @service_validate_url
          url << '&t=' << Rack::Utils.escape(ticket)
        end

        private
          def parse_params(params)
            @login_url = SERVICE_LOGIN_URL % params[:server]
            validate_is_url 'login URL', @login_url

            @service_validate_url = SERVICE_VALIDATE_URL % params[:server]
            validate_is_url 'service-validate URL', @service_validate_url

            @service = params[:service]
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
          def append_service(base)
            result = base.dup
            result << (result.include?('?') ? '&' : '?')
            result << 's='
            result << Rack::Utils.escape(@service)
          end
      end
    end
  end
end
