class AuthsController < ApplicationController
    def create
        index
    end

    def index
        case params[:intent]
        when 'list'
            finish_with Auth.where('authorizer = ? and authorizee != "*"', params[:username])

        when 'create'
            unless User.find_by username: params[:authorizee]
                error "不存在学号为 #{params[:authorizee]} 的考生"
                return
            end

            Auth.create(
                authorizer: params[:authorizer],
                authorizee: params[:authorizee],
                auth_code: UUID.new.generate,
                remaining: 1
            )
            errorcode 0

        when 'destroy'
            ActiveRecord::Base.connection.execute "DELETE FROM auths WHERE auth_code = '#{params[:auth_code]}'"
            errorcode 0

        else
            render html: 'else'

        end
    end
end
