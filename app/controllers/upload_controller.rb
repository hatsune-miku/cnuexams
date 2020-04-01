class UploadController < ApplicationController

    NAME_TABLE = {
        users: {
            学号: 'username',
            姓名: 'name',
            学院: 'institute',
            专业: 'major',
            初始密码: 'password'
        },
        exams: {
            考试名称: 'name',
            及格线: 'requirement',
            通过后可再考？: 'retestable',
            考试时间: 'time_limit',
            每日参加次数上限: 'attend_limit',
            是否公开: 'public',
            分数政策: 'policy'
        },
        questions: {
            题干: 'summary',
            选项: 'options',
            答案: 'answer',
            分值: 'score',
            固定题？: 'essential',
            题目类型: 'cate',
            选项类型: 'kind',
            '所属考试 ID': 'exam',
            标签: 'label'
        },
        institutes: {
            学院名称: 'name',
            理科题比例: 'mathp',
            文科题比例: 'artp',
            通用题比例: 'generalp',
            文or理: 'kind'
        }
    }


    def create
        index
    end

    def index
        file = params[:file]
        db = params[:db]
        unless file
            error 'no files provided.'
            return
        end

        book = Creek::Book.new(file.tempfile)
        sheet = book.sheets[0]
        header = sheet.rows.take(1).first.values
        data = []

        sheet.rows.drop(1).each do |row|
            dat = {}
            row.values.each_with_index do |v, i|
                unless v
                    dat = {}
                    break
                end
                
                dat[NAME_TABLE[db.to_sym][header[i].to_sym]] = v
            end
            break if dat == {}
            data << dat
        end

        # sql inject?
        if db.include? ';'
            error '非法数据库信息'
            return
        end

        entity = eval(db.singularize.capitalize)
        data.each_slice(3000) do |slice|
            entity.import slice
        end
        errorcode 0, '导入完成'
    end
end
