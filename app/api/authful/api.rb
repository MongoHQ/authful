module Authful
  class API < Grape::API
    format :json

    helpers do
      def current_account
        @current_account ||= Account.where(token: headers['Api-Token']).first
      end

      def require_account!
        error!({error: '401 Unauthorized'}, 401) unless current_account
      end

      def current_user
        @current_user ||= current_account.users.where(token: params[:id]).first
      end

      def require_user!
        error!({error: '404 Not Found'}, 404) unless current_user
      end

      def qr_url(user)
        user.activate_qr_code
        "//#{request.env["HTTP_HOST"]}#{user.qr_url}"
      end

      def send_sms(user)
        status, message = user.send_sms

        if user.sms_user?
          unless status
            error!({error: message}, 400)
          end
        else
          error!({error: "no phone for user"}, 409)
        end

        true
      end
    end

    namespace :users do
      desc "enroll a user"
      params do
        requires :email, type: String, desc: "email for a user"
        optional :phone, type: String, desc: "phone number to use for primary"
      end
      post '/' do
        require_account!
        if user = User.where(email: params[:email]).first
          error!({error: "already enrolled"}, 409)
        else
          user = User.create!(account: current_account, email: params[:email], phone: params[:phone])

          res = {ok: 1, token: user.token, email: user.email, secret: user.secret}
          if user.sms_user?
            status, message = user.send_sms

            if status
              res.merge!(phone: user.phone)
            else
              user.destroy
              error!({error: message}, 400)
            end
          else
            res.merge!(qr_code: qr_url(user))
          end
          return res
        end
      end

      desc "view a user"
      get ':id' do
        require_account!
        require_user!
        {ok: 1, email: current_user.email, enrollment_type: current_user.enrollment_type, number: current_user.phone, fallback_phone: current_user.fallback_phone}
      end

      desc "unenroll a user"
      delete ':id' do
        require_account!
        require_user!
        current_user.destroy
        {ok: 1}
      end

      desc "validate an OTP"
      params do
        requires :token, type: String, desc: "OTP to be validated"
      end
      get ':id/validate' do
        require_account!
        require_user!
        if current_user.validate(params[:token])
          {ok: 1}
        else
          error!({error: "invalid token"}, 403)
        end
      end

      desc "send a sms message with code"
      get ':id/send_sms' do
        require_account!
        require_user!

        send_sms(current_user)

        {ok: 1}
      end

      desc "reset a users secret"
      patch ':id/reset' do
        require_account!
        require_user!

        current_user.update_attributes(secret: User.generate_token)

        res = {ok: 1, email: current_user.email, secret: current_user.secret}
        if current_user.sms_user?
          send_sms(current_user)
          res.merge!(phone: current_user.phone)
        else
          res.merge!(qr_code: qr_url(current_user))
        end
        return res
      end

      desc "update a users fallback phone number"
      params do
        requires :phone, type: String, desc: "users phone number"
      end
      patch ':id/fallback' do
        require_account!
        require_user!

        begin
          current_user.update_attributes!(fallback_phone: params[:phone])
          current_user.send_fallback_sms(true)
        rescue
          error!({error: "couldn't update phone for user"}, 400)
        end

        {ok: 1}
      end

      desc "send code to a users fallback phone number"
      get ':id/fallback' do
        require_account!
        require_user!

        status, message = current_user.send_fallback_sms

        if status
          {ok: 1}
        else
          error!({error: message}, 400)
        end
      end

      desc "generate recovery codes"
      post ":id/recovery_codes" do
        require_account!
        require_user!

        current_user.generate_recovery_codes

        {ok: 1, recovery_codes: current_user.recovery_codes.map{|c| c.chars.each_slice(5).map(&:join).join("-")}}
      end

      desc "view remaining recovery codes"
      get ":id/recovery_codes" do
        require_account!
        require_user!

        {ok: 1, recovery_codes: current_user.recovery_codes.map{|c| c.chars.each_slice(5).map(&:join).join("-")}}
      end

      desc "validate recovery code"
      get ":id/recovery_codes/:code" do
        require_account!
        require_user!

        unless current_user.validate_recovery_code(params[:code])
          error!({error: "invalid recovery code"}, 403)
        end

        {ok: 1}
      end
    end
  end
end
