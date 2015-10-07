require 'spec_helper'

describe "User pages -" do

  subject { page }

  describe "SignUp page -" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "With invalid information -" do
      it "Should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "With valid information -" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "Should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "After saving the user -" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it "Should have sign out link"      do should have_link('Sign out') end
        it "Should have user name in title" do should have_title(user.name) end

        it "Should have welcome flash" do
          should have_selector('div.alert.alert-success', text: 'Welcome')
        end
      end
    end

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