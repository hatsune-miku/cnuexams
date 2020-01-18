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
end
