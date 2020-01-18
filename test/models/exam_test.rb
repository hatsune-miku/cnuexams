require 'test_helper'

class ExamTest < ActiveSupport::TestCase
    Exam.create(
            name: '研究生学术不端测试 (文科)',
            requirement: 60,
            retestable: 0,
            time_limit: 2 * 60 * 60,
            limit: -1,
            public: true
    )
end
