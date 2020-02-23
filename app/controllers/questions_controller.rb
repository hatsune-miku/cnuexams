class QuestionsController < ApplicationController
    def create
        index
    end

    def index
        crud Question, '题目', '道'
    end
end
