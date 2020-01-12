class User < ApplicationRecord
  validates :username, uniqueness: true
  validates_length_of :password, minimum: 6, maximum: 64, message: '密码长度应为 6~64 位'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  def passed?(exam_id)
    passed_exams.include? "#{exam_id}:"
  end
end
