class ExamQuestionKindsController < ApplicationController

    def index
        exam_id = params[:exam_id]
        labels = Question.where("exam like '%#{exam_id}%'").distinct(:label).pluck(:label)
        labels.each do |label|
            eqks = ExamQuestionKind.where label: label
            if eqks.count == 0
                ExamQuestionKind.create(exam_id: exam_id, label: label, proportion: 0)
            end
        end
        @eqks = ExamQuestionKind.where(exam_id: exam_id)
    end

    def show
        @eqk
    end 

    def create
        @eqk = ExamQuestionKind.create(exam_question_kind_params)
    end

    def update
        exam_id = params[:exam_id]
        data = params[:data]
        p exam_id, data
        data.each_pair do |k, v|
            ExamQuestionKind.find_by(exam_id: exam_id, label: k).update(proportion: v)
        end
    end

    def destroy
        @eqk.destroy
    end


    private

    def exam_question_kind_params
        params.require(:exam_question_kind).permit(:id, :exam_id, :label, :proportion)
    end
end
