require 'spec_helper'

describe "User pages - " do

  subject { page }

  describe "SignUp page - " do
    before { visit signup_path }

    it "Should have h1 'Sign up'"    do should have_selector('h1', text: 'Sign up') end
    it "Should have title 'Sign up'" do should have_title(full_title('Sign up')) end
  end
end