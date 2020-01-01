class ExamsController < ApplicationController

    def index
        create
    end

    def create
        intent = params[:intent]
        case intent

        when 'list'
            finish_with Exam.all

        when 'start'
            # exam start!
            session_id = params[:session_id]
            username = params[:username]
            exam_id = params[:exam_id]

            return unless verified_session_id?(username, session_id)

            exam = Exam.find_by id: exam_id

            # check if irretestable.
            if exam.irretestable? and @current_user.passed? exam_id
                error '不可重复参加'
                return
            end

            institute = Institute.find_by name: @current_user.institute

            artp = institute.artp
            mathp = institute.mathp

            generalp = institute.generalp
            filep = Customcate.find_by(name: 'file').perportion * generalp
            otherp = Customcate.find_by(name: 'other').perportion * generalp
            videop = Customcate.find_by(name: 'video').perportion * generalp

            mathq = Question.sample(exam_id, '0', mathp)
            artq = Question.sample(exam_id, '1', artp)
            otherq  = Question.sample(exam_id, '2', otherp)
            fileq  = Question.sample(exam_id, '3', filep)
            videoq  = Question.sample(exam_id, '4', videop)

            @current_user.update exam_id: exam_id

            questions = mathq + artq + otherq + fileq + videoq

            # save session, start timing and remove saved answers.
            @current_user.update time_started: Time.now,
                                 time_submitted: 0,
                                 last_score: 0,
                                 question_ids: questions.pluck(:id).join(','),
                                 saved_answers: ''

            finish_with questions.shuffle

        when 'save_status'
            session_id = params[:session_id]
            username = params[:username]
            answers = params[:current_answers]

            return unless verified_session_id?(username, session_id)

            p answers

            @current_user.update saved_answers: answers
            errorcode 0

        when 'restart'
            session_id = params[:session_id]
            username = params[:username]

            return unless verified_session_id?(username, session_id)

            question_ids = @current_user.question_ids.split(',')

            if question_ids.length == 0
                # not attended or no questions.
                error '无题目'
                return
            end

            ret = {
                questions: [],
                saved_answers: nil
            }

            question_ids.each do |id|
                question = Question.find_by id: id
                ret[:questions] << {
                    id: id,
                    summary: question.summary,
                    options: question.options,
                    score: question.score,
                    essential: question.essential,
                    kind: question.kind,
                    cate: question.cate
                }
            end

            ret[:saved_answers] = @current_user.saved_answers

            finish_with ret

        when 'judge'
            session_id = params[:session_id]
            username = params[:username]
            answers = params[:answers].split '##'

            unless verified_session_id?(username, session_id)
                redirect_to '/'
                return
            end

            hit = 0
            miss = 0
            score = 0
            i = 0

            exam = Exam.find_by id: @current_user.exam_id
            qids = @current_user.question_ids.split ','

            qids.each do |qid|
                question = Question.find_by id: qid
                given_ans = answers[i]
                i += 1

                p question.answer.chars.sort
                p given_ans

                if question.answer.chars.sort == given_ans.chars.sort
                    hit += 1
                    score += question.score
                else
                    miss += 1
                end
            end

            # clear saved_answers.
            @current_user.update question_ids: ''

            finish_with hit: hit, miss: miss, score: score, passed: score >= exam.requirement

        else
            render html: 'else'

        end
    end

    def verified_session_id?(username, given_session_id)
        @current_user = User.find_by username: username
        real_session_id = @current_user.session_id

        # check if session_id is incorrect.
        unless given_session_id == real_session_id
            error 'session_id 不正确'
            return false
        end
        true
    end

end
