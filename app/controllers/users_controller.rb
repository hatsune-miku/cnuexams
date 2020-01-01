class UsersController < ApplicationController

    def index
        create
    end

    def create
        intent = params[:intent]
        case intent
        when 'login'
            username = params[:username]
            password = params[:password]

            @current_user = User.find_by username: username
            if (current_user == nil) or (@current_user.password != password)
                error '学号或密码错误'
                return
            end

            session_id = UUID.new.generate
            @current_user.session_id = session_id
            @current_user.save

            finish_with session_id: session_id, name: @current_user.name

        when 'reuse'
            session_id = params[:sessionId]
            current_user = User.find_by session_id: session_id
            if session_id.empty? or current_user == nil
                return
            end
            finish_with session_id

        when 'logout'
            render html: 'logout.'

        when 'info'
            username = params[:username]
            @current_user = User.find_by username: username

            pref = Preference.find_by(name: 'login_limit').value.to_i
            pref = '∞' if pref < 0
            limit_desc = "#{@current_user.login_count} / #{pref}"

            finish_with name: @current_user.name, institute: @current_user.institute,
                        major: @current_user.major, limit: limit_desc

        when 'history'
            username = params[:username]
            records = Record.where :username => username

            ret = []
            records.each do |record|
                exam_id = record.exam_id
                exam = Exam.find_by id: exam_id

                requirement = exam.requirement
                score = record.score

                ret << {
                    time: record.created_at.to_s,
                    examName: exam.name,
                    score: record.score,
                    passedOrNot: score >= requirement ? 'Yes' : 'No'
                }
            end

            finish_with ret

        else
            render html: 'else.'

        end
    end
end
