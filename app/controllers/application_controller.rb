require 'uuid'

class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def current_user
        @current_user = User.find_by username: session[:user_id] unless @current_user
        @current_user
    end

    def error(msg)
        flash[:alert] = msg
        render json: {
            errorcode: -1,
            message: msg
        }
    end

    def errorcode(code)
        render json: {
            errorcode: code
        }
    end

    def parse_error(errors)
        errors.each { |_, err| err }.join ', '
    end

    def finish_with(res)
        flash[:notice] = '操作成功'
        render json: {
            errorcode: 0,
            message: '操作成功',
            response: res
        }
    end

    def authenticate_user
        if current_user == nil
            redirect_to '/'
        end
    end

    def index
        create
    end

    def create
        render html: '204'
    end

end
