require 'test_helper'

class MemberTest < ActiveSupport::TestCase
    Member.create(username: 'root', password: '111111')
end
