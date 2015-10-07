require 'spec_helper'

describe "Authentication -" do

  subject { page }

  describe "SignIn page -" do
    before { visit signin_path }

    describe "With invalid information -" do
      before { click_button "Sign in" }

      it "Should have selector 'alert-error'" do should have_selector('div.alert.alert-error') end

      describe "After visiting another page -" do
        before { click_link "Home" }
        it "Should not have selector 'alert-error'" do
          should_not have_selector('div.alert.alert-error')
        end
      end
    end

    describe "With valid information -" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it "Should have user name in title" do should have_title(user.name) end
      it "Should have link to profile"    do should have_link('Profile', href: user_path(user)) end
      it "Should have link to signOut"    do should have_link('Sign out', href: signout_path) end
      it "Should have link to signIn"     do should_not have_link('Sign in', href: signin_path) end
    end

    it "Should have content 'Sing in'" do should have_content('Sign in') end
    it "Should have title 'Sing in'"   do should have_title('Sign in') end
  end
end
