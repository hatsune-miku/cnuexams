require 'test_helper'

class CustomcateTest < ActiveSupport::TestCase
    Customcate.create(name: 'file', perportion: 0.2)
    Customcate.create(name: 'other', perportion: 0.5)
    Customcate.create(name: 'video', perportion: 0.3)
end
