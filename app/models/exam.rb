class Exam < ApplicationRecord
    def irretestable?
        retestable == 0
    end

    def question_analysis(start_time, finish_time)
        records = Record.where 'exam_id = ? and created_at between ? and ?', self.id, start_time, finish_time
        questions = {}

        records.each do |record|
            ans = record.ans.split('##')
            real_ans = record.real_ans.split('##')
            question_ids = record.question_ids.split(',')
            
            question_ids.each_with_index do |question_id, i|
                question = Question.find_by id: question_id
                questions[question_id] ||= { id: question_id, summary: question.summary, hit: 0, miss: 0 }

                if ans[i].chars.sort == real_ans[i].chars.sort
                    questions[question_id][:hit] += 1
                else
                    questions[question_id][:miss] += 1
                end
            end
        end
        questions
    end
end
