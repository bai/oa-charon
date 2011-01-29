module OmniAuth
  module Strategies
    class Remote
      include OmniAuth::Strategy
      
      autoload :Configuration, "omniauth/strategies/remote/configuration"
      autoload :ServiceTicketValidator, "omniauth/strategies/remote/service_ticket_validator"
      
      def initialize(app, options = {}, &block)
        super(app, options.delete(:name) || :remote, options, &block)
        @configuration = OmniAuth::Strategies::Remote::Configuration.new(options)
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
          ticket = request.params["t"]
          return fail!(:no_ticket) unless ticket
          validator = ServiceTicketValidator.new(@configuration, callback_url, ticket)
          @user_info = validator.user_info
          return fail!(:invalid_ticket) if @user_info.nil? || @user_info.empty?
          super
        end

        def auth_hash
          OmniAuth::Utils.deep_merge(super, {
            "uid" => @user_info.delete("user"),
            "extra" => @user_info
          })
        end
    end
  end
end
