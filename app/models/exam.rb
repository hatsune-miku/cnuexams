class Exam < ApplicationRecord
    def irretestable?
        retestable == 0
    end
end
