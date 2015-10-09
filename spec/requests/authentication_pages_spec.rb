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
      before { sign_in user}

      it "Should have user name in title" do should have_title(user.name) end
      it "Should have link to profile"    do should have_link('Profile', href: user_path(user)) end
      it "Should have link to settings"   do should have_link('Settings', href: edit_user_path(user)) end
      it "Should have link to signOut"    do should have_link('Sign out', href: signout_path) end
      it "Should have link to signIn"     do should_not have_link('Sign in', href: signin_path) end

      describe "Followed by sign out -" do
        before { click_link "Sign out" }
        it "Should have link sign in" do should have_link('Sign in') end
      end
    end

    it "Should have content 'Sing in'" do should have_content('Sign in') end
    it "Should have title 'Sing in'"   do should have_title('Sign in') end
  end

  describe "Authorization -" do

    describe "For non-signed-in users -" do
      let(:user) { FactoryGirl.create(:user) }

      describe "In the Users controller -" do

        describe "Visiting the edit page -" do
          before { visit edit_user_path(user) }
          it "Should have title 'Sign In'" do should have_title('Sign in') end
        end

        describe "Submitting to the update action -" do
          before { patch user_path(user) }
          specify "Should redirect to sign in" do expect(response).to redirect_to(signin_path) end
        end
      end
    end

    describe "As wrong user -" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "Submitting a GET request to the Users#edit action -" do
        before { get edit_user_path(wrong_user) }

        specify "Should not have title 'Edit user'" do
          expect(response.body).not_to match(full_title('Edit user'))
        end

        specify "Should redirect to root path" do expect(response).to redirect_to(root_url) end
      end

      describe "Submitting a PATCH request to the Users#update action -" do
        before { patch user_path(wrong_user) }
        specify "Should redirect to root path" do expect(response).to redirect_to(root_url) end
      end
    end
  end

end
