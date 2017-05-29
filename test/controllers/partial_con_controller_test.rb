require 'test_helper'

class PartialConsControllerTest < ActionController::TestCase
  setup do
    @partial_con = partial_cons(:partial_con1)

    user_log_in
  end

  #todo: do real tests
end