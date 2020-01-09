require 'uuid'

class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    attr_accessor :current_user

    def login_limit
        @login_limit = Preference.find_by(name: 'login_limit').value.to_i unless @login_limit
        @login_limit
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

    def finish_with(res)
        flash[:notice] = '操作成功'
        render json: {
            errorcode: 0,
            message: '操作成功',
            response: res
        }
    end

    def authenticate_user
        if :current_user == nil
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
