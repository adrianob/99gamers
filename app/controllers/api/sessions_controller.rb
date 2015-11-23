class Api::SessionsController < Devise::SessionsController
    protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/vnd.myapp.v1' }

    def create
      warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
      render :json => { :info => "Logged in", :user => current_user }, :status => 200
    end

    def failure
      render :json => { :error => "Login Credentials Failed" }, :status => 401
    end
end
