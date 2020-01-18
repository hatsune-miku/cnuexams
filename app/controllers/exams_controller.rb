class ExamsController < ApplicationController

    def index
        create
    end

    def verified_exam_limit?(exam)
        limit = exam.limit || 0

        # ensure exam_limit.
        exam_limit = ExamLimit.find_by username: current_user.username,
                                       exam_id: exam.id

        unless exam_limit
            exam_limit = ExamLimit.create(username: current_user.username,
                                          exam_id: exam.id,
                                          current: 0,
                                          locked_before: 0,
                                          last_login: Time.now
            )
        end

        return true if limit < 0

        # check if provided auth_code.
        if params[:auth_code]
            auth = Auth.find_by auth_code: params[:auth_code]
            unless auth
                error '授权码无效'
                return false
            end

            unless auth.authorizee == current_user.username or auth.authorizee == '*'
                error '人码不匹配'
                return false
            end

            remaining = auth.remaining
            if remaining == 1
                auth.destroy
            elsif remaining > 1
                auth.remaining = remaining - 1
                auth.save
            end

        else

            # check if locked?
            locked_before = Time.at exam_limit.locked_before
            if Time.now < locked_before
                error "连续不及格次数超过 3 次啦！<br/>下次考试将在 #{locked_before} 时准时开放。"
                return false
            end

            # check if last_login < yesterday?
            if Time.now.day > Time.at(exam_limit.last_login).day
                # last login is on at least yesterday.
                # reset login count.
                exam_limit.current = 0
            else
                # last login is on today.
                if exam_limit.current >= limit
                    error '考试次数超出限制'
                    return false
                end
            end

            exam_limit.last_login = Time.now
            exam_limit.current += 1
            exam_limit.save
        end

        true
    end

    def create
        intent = params[:intent]
        case intent

        when 'list'
            finish_with Exam.where public: true

        when 'start'
            # exam start!
            session_id = params[:session_id]
            exam_id = params[:exam_id]
            given_major = params[:given_major]

            exam = Exam.find_by id: exam_id

            return unless verified_session_id?(session_id) and verified_exam_limit?(exam)

            # check if irretestable.
            if exam.irretestable? and current_user.passed? exam_id
                error '不可重复参加'
                return
            end

            case given_major
            when nil
                institute = Institute.find_by name: current_user.institute
                artp = institute.artp
                mathp = institute.mathp
                generalp = institute.generalp

            when 0
                artp = 0
                mathp = 0.8
                generalp = 0.2

            when 1
                artp = 0.8
                mathp = 0
                generalp = 0.2

            else
                artp = 0
                mathp = 0
                generalp = 0

            end

            filep = Customcate.find_by(name: 'file').perportion * generalp
            otherp = Customcate.find_by(name: 'other').perportion * generalp
            videop = Customcate.find_by(name: 'video').perportion * generalp

            mathq = Question.sample(exam_id, 0, mathp)
            artq = Question.sample(exam_id, 1, artp)
            otherq  = Question.sample(exam_id, 2, otherp)
            fileq  = Question.sample(exam_id, 3, filep)
            videoq  = Question.sample(exam_id, 4, videop)

            current_user.update exam_id: exam_id

            questions = mathq + artq + otherq + fileq + videoq

            # save session, start timing and remove saved answers.
            current_user.update time_started: Time.now,
                                 time_submitted: 0,
                                 question_ids: questions.pluck(:id).join(','),
                                 saved_answers: ''

            finish_with questions

        when 'save_status'
            session_id = params[:session_id]
            answers = params[:current_answers]

            return unless verified_session_id?(session_id)

            p answers

            current_user.update saved_answers: answers
            errorcode 0

        when 'restart'
            session_id = params[:session_id]

            return unless verified_session_id?(session_id)

            question_ids = current_user.question_ids.split(',')

            if question_ids.length == 0
                # not attended or no questions.
                error '无题目'
                return
            end

            ret = {
                questions: [],
                saved_answers: current_user.saved_answers
            }

            last_label = ''
            question_ids.each do |id|
                question = Question.find_by id: id

                ret[:questions] << {
                    id: id,
                    summary: question.summary,
                    options: question.options,
                    score: question.score,
                    essential: question.essential,
                    kind: question.kind,
                    cate: question.cate,
                    label: question.label == last_label ? '' : question.label
                }

                last_label = question.label
            end

            finish_with ret

        when 'judge'
            session_id = params[:session_id]
            answers = params[:answers].split '##'

            unless verified_session_id?(session_id)
                redirect_to '/'
                return
            end

            hit = 0
            miss = 0
            score = 0
            i = 0

            exam = Exam.find_by id: current_user.exam_id

            # check if not submitting on time.
            time_elapsed = Time.now.to_i - current_user.time_started
            if time_elapsed - exam.time_limit > 60
                # clear saved_answers.
                current_user.update question_ids: '', exam_id: 0

                error "你错过了考试(#{exam.name})的提交时间"
                return
            end

            qids = current_user.question_ids.split ','
            real_ans = []

            qids.each do |qid|
                question = Question.find_by id: qid
                given_ans = answers[i]
                i += 1

                ans = question.answer
                real_ans << ans

                if ans.chars.sort == given_ans.chars.sort
                    hit += 1
                    score += question.score
                else
                    miss += 1
                end
            end

            # judge policy.
            policy = exam.policy
            should_record = case policy
                            # override only.
                            when 0
                                true

                            # higher.
                            when 1
                                Record.exists? 'username = ?, exam_id = ?, score > ?',
                                               current_user.username,
                                               exam.id,
                                               score

                            # lower.
                            when 2
                                Record.exists? 'username = ?, exam_id = ?, score < ?',
                                               current_user.username,
                                               exam.id,
                                               score

                            else
                                true

                            end

            # make record.
            Record.create(
                username: current_user.username,
                question_ids: current_user.question_ids,
                ans: answers.join('##'),
                real_ans: real_ans,
                time_elapsed: time_elapsed,
                exam_id: exam.id,
                score: score,
                hit: hit,
                miss: miss
            ) if should_record

            # clear saved_answers.
            current_user.update question_ids: '', exam_id: 0
            passed = score >= exam.requirement

            unless passed
                exam_limit = ExamLimit.find_by username: current_user.username,
                                               exam_id: exam.id
                exam_limit.fail_count += 1

                if exam_limit.fail_count >= 3
                    exam_limit.fail_count = 0
                    exam_limit.locked_before = Time.now + (14 * 24 * 60 * 60)
                end

                exam_limit.save
            end

            finish_with hit: hit, miss: miss, score: score, ans: real_ans,
                        passed: passed, time_elapsed: time_elapsed

        else
            render html: 'else'

        end
    end

    def verified_session_id?(given_session_id)
        # check if session_id is incorrect.
        unless given_session_id == current_user.session_id
            error 'session_id 不正确'
            return false
        end
        true
    end

end
