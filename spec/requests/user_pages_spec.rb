require 'spec_helper'

describe "User pages - " do

  subject { page }

  describe "SignUp page - " do
    before { visit signup_path }

    it "Should have h1 'Sign up'"    do should have_selector('h1', text: 'Sign up') end
    it "Should have title 'Sign up'" do should have_title(full_title('Sign up')) end
  end

  describe "Profile page -" do
    before { visit user_path(user) }

    let(:user) { FactoryGirl.create(:user) }
    let(:name) {user.name}

    it "Should have user name in content " do should have_content(name) end
    it "Should have user name in title "   do should have_title(name) end
  end
end