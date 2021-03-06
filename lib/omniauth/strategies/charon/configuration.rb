module OmniAuth
  module Strategies
    class Charon
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
          service = service.sub(/[?&]ticket=[^?&]+/, '')
          url = append_service(@service_validate_url)
          url << '&ticket=' << Rack::Utils.escape(ticket)
        end

        private
          def parse_params(params)
            @login_url = SERVICE_LOGIN_URL % params[:server]
            @service_validate_url = SERVICE_VALIDATE_URL % params[:server]
            @service = params[:service]
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
            result << 'service='
            result << Rack::Utils.escape(@service)
          end
      end
    end
  end
end
