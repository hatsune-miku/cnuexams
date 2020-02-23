class User < ApplicationRecord
  validates :username, uniqueness: true
  validates_length_of :password, minimum: 6, maximum: 64, message: '密码长度应为 6~64 位'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  def passed?(exam_id)
    records = Record.where exam_id: exam_id, username: username
    exam = Exam.find_by id: exam_id

    return false unless records and exam

    records.each do |record|
      return true if record.score >= exam.requirement
    end
    false
  end

  def self.spacelens(offset, limit)
    ret = []
    users = User.limit(limit).offset(offset).all
    users.each do |user|

      status = if user.time_started == 0
                 '尚未考试'
               elsif user.time_submitted == 0
                 '正在考试'
               else
                 'error'
               end

      record = Record.where(username: user.username).last
      if record
        time_elapsed = record.time_elapsed
        score = record.score
        passed = score >= Exam.find_by(id: record.exam_id).requirement ? 'Yes' : 'No'
      else
        time_elapsed = '-'
        score = '-'
        passed = '-'
      end

      ret << {
          username: user.username,
          name: user.name,
          institute: user.institute,
          major: user.major,
          exam_id: user.exam_id,
          status: status,
          time_started: user.time_started,
          time_submitted: user.time_submitted,
          time_elapsed: time_elapsed,
          score: score,
          passed: passed
      }
    end
    ret

  end
end
