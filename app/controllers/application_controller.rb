require 'uuid'

class ApplicationController < ActionController::Base
    # protect_from_forgery with: :exception

    def crud(entity, entity_name, measure = '个', where_cond = nil)

        where_cond ||= params[:where]

        case params[:intent]

            # C
        when 'create', 'new'
            @entity = entity.new(params_for :create)
            if @entity.save
                errorcode 0, "创建了一#{measure}#{entity_name}"
            else
                error parse_error(@entity.errors)
            end

            # R
        when 'list', 'retrieve'
            if where_cond
                p 'using where', where_cond
                finish_with entity.where(where_cond).limit(params[:limit] || 999999).offset(params[:offset] || 0).all
            else
                p 'not using where'
                finish_with entity.limit(params[:limit] || 999999).offset(params[:offset] || 0).all
            end

        when 'count'
            finish_with count: entity.where(where_cond).count

            # U
        when 'update', 'edit'
            param = params_for :update

            # both id and username are available in cnu exams.
            if param[:id]
                @entity = entity.find_by(id: param[:id])
            else
                @entity = entity.find_by(username: param[:username])
            end

            if @entity.update(param)
                errorcode 0, "更新了一#{measure}#{entity_name}"
            else
                error parse_error(@entity.errors)
            end

            # D
        when 'destroy', 'delete', 'remove', 'erase'
            entity.destroy(params_for :destroy)
            errorcode 0, "删除了一#{measure}#{entity_name}"

        else
            return false

        end

        true
    end

    def params_for(action)
        case action
        when :create, :update
            params[:data].permit!

        when :destroy
            if params[:data].is_a? Array
                params[:data].pluck :id
            else
                params[:data][:id]
            end

        else
            raise 'unexpecteed action. acceptable actions: :create, :update, :destroy.'

        end
    end

    def current_user
        @current_user = User.find_by username: session[:user_id] unless @current_user
        @current_user
    end

    def current_member
        @current_member = Member.find_by username: session[:member_id] unless @current_member
        @current_member
    end

    def error(msg)
        flash[:alert] = msg
        render json: {
            errorcode: -1,
            message: msg
        }
    end

    def errorcode(code, message = nil)
        if code != 0
            render json: {
                errorcode: code
            }
        else
            render json: {
                errorcode: code,
                message: message || '操作成功'
            }
        end
    end

    def parse_error(errors)
        errors = [errors] unless errors.is_a? Array
        errs = []
        errors.each { |err| errs << err.messages.values }
        errs.join ', '
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
