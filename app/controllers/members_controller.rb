class MembersController < ApplicationController

    def index
        create
    end


    def create
        return if crud Member, '教师', '位'

        intent = params[:intent]
        case intent
        when 'login'
            username = params[:username]
            password = params[:password]

            member = Member.find_by username: username

            if (member == nil) or (member.password != password)
                error '用户名或密码错误'
                return
            end

            session_id = UUID.new.generate
            member.session_id = session_id
            member.save

            session[:member_id] = member.username

            finish_with session_id: session_id, name: member.username

        when 'reset'
            username = params[:username]
            password = params[:password]
            new_password = params[:new_password]

            member = Member.find_by username: username

            if member == nil or member.password != password
                error '用户名或密码错误'
                return
            end

            if member.update password: new_password
                errorcode 0
            else
                error parse_error(member.errors)
            end

        when 'reuse'
            session_id = params[:sessionId]
            member = Member.find_by session_id: session_id

            if member == nil or session_id.empty?
                return
            end

            session[:member_id] = member.username
            finish_with session_id

        when 'logout'
            render html: 'logout.'

        end
    end
end
