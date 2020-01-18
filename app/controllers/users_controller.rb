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

            user = User.find_by username: username

            if (user == nil) or (user.password != password)
                error '学号或密码错误'
                return
            end

            session_id = UUID.new.generate
            user.session_id = session_id
            user.save

            session[:user_id] = user.id

            finish_with session_id: session_id, name: user.name

        when 'reset'
            username = params[:username]
            password = params[:password]
            new_password = params[:new_password]

            user = User.find_by username: username

            if (user == nil) or (user.password != password)
                error '学号或密码错误'
                return
            end

            if user.update password: new_password
                errorcode 0
            else
                error parse_error(user.errors)
            end

        when 'reuse'
            session_id = params[:sessionId]
            user = User.find_by session_id: session_id

            if user == nil or session_id.empty? or current_user == nil
                return
            end

            session[:user_id] = user.id
            finish_with session_id

        when 'logout'
            render html: 'logout.'

        when 'info'
            username = params[:username]
            current_user = User.find_by username: username

            exam_id = current_user.exam_id
            exam = Exam.find_by id: exam_id
            exam_name = nil
            exam_time_limit = 2 * 60 * 60

            if exam
                exam_name = exam.name
                exam_time_limit = exam.time_limit
            else
                exam_id = 0
            end

            finish_with name: current_user.name,
                        institute: current_user.institute,
                        major: current_user.major,
                        exam_id: exam_id,
                        exam_name: exam_name,
                        time_started: current_user.time_started,
                        time_limit: exam_time_limit

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
                    id: record.id,
                    time: record.created_at.to_s,
                    examName: exam.name,
                    score: record.score,
                    passedOrNot: score >= requirement ? 'Yes' : 'No',
                    time_elapsed: record.time_elapsed,
                    hit: record.hit,
                    miss: record.miss
                }
            end

            # newer records should be on top.
            finish_with ret.reverse

        else
            render html: 'else.'

        end
    end
end
