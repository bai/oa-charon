module OmniAuth
  module Strategies
    class Charon
      include OmniAuth::Strategy

      autoload :Configuration, "omniauth/strategies/charon/configuration"
      autoload :ServiceTicketValidator, "omniauth/strategies/charon/service_ticket_validator"

      def initialize(app, options = {}, &block)
        super(app, options.delete(:name) || :charon, options, &block)
        @configuration = OmniAuth::Strategies::Charon::Configuration.new(options)
      end

      protected
        def request_phase
          [
            302,
            {
              "Location" => @configuration.login_url,
              "Content-Type" => "text/plain"
            },
            [ "You are being redirected for sign-in." ]
          ]
        end

        def callback_phase
          ticket = request.params["ticket"]
          return fail!(:no_ticket, 'No ticket') unless ticket
          validator = ServiceTicketValidator.new(@configuration, callback_url, ticket)
          @user_info = validator.user_info
          return fail!(:invalid_ticket, 'Invalid ticket') if @user_info.nil? || @user_info.empty?
          super
        end

        def auth_hash
          OmniAuth::Utils.deep_merge(super, {
            "uid" => @user_info["name"],
            "user_info" => @user_info
          })
        end
    end
  end
end
