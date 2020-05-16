class Question < ApplicationRecord

    MAX_QUESTIONS_COUNT = 50.freeze

    def self.sample(exam_id, cate, perportion)
        exam = Exam.find(exam_id)
        eqks = exam.exam_question_kinds
        eqks.map do |eqk|
            where('exam like ? and cate = ? and label = ?', "%#{exam_id}%", cate, eqk.label)\
                .order(essential: :desc)\
                .limit(MAX_QUESTIONS_COUNT * perportion * eqk.proportion)
        end.flatten
    end
end
