class Question < ApplicationRecord

    MAX_QUESTIONS_COUNT = 50

    def self.sample(exam_id, cate, perportion)
        where('exam like ? and cate = ?', "%#{exam_id}%", cate)
            .group(:cate, :id, :label)
            .order('rand()', essential: :desc)
            .limit(MAX_QUESTIONS_COUNT * perportion)
    end
end
