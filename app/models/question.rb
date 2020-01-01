class Question < ApplicationRecord

    MAX_QUESTIONS_COUNT = 50

    def self.sample(exam_id, cate, perportion)
        where(exam: exam_id, cate: cate)
            .order('rand()', essential: :desc)
            .limit(MAX_QUESTIONS_COUNT * perportion)
    end
end
