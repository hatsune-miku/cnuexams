class User < ApplicationRecord
  validates :username, uniqueness: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  def passed?(exam_id)
    passed_exams.include? "#{exam_id}:"
  end
end
