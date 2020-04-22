class QuestionsController < ApplicationController
    def create
        index
    end

    def index
        case params[:intent]
        when 'list', 'retrieve'
            finish_with Question.where(params[:where]).limit(params[:limit] || 1000).offset(params[:offset] || 1000).order(:label)
        
        else
            crud Question, '题目', '道'
        end
    end
end
