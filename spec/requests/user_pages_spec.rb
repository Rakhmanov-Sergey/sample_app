require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "SignUp page" do
    before { visit signup_path }

    it "Should have content 'Sign up'" do should have_content('Sign up') end
    it "Should have title 'Sign up'"   do should have_title(full_title('Sign up')) end
  end
end