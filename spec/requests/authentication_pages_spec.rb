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
      it "Should have link to users"      do should have_link('Users', href: users_path) end
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

    describe "As non-admin user -" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "Submitting a DELETE request to the Users#destroy action -" do
        before { delete user_path(user) }
        specify "Should be redirect to root" do expect(response).to redirect_to(root_url) end
      end
    end

    describe "For non-signed-in users -" do
      let(:user) { FactoryGirl.create(:user) }

      describe "In the Microposts controller -" do

        describe "Submitting to the create action -" do
          before { post microposts_path }
          specify "Should redirect to signin page" do expect(response).to redirect_to(signin_path) end
        end

        describe "Submitting to the destroy action -" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify "Should redirect to signin page" do expect(response).to redirect_to(signin_path) end
        end
      end

      describe "When attempting to visit a protected page -" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "After signing in -" do

          it "Should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end

      describe "In the Users controller -" do

        describe "Visiting the edit page -" do
          before { visit edit_user_path(user) }
          it "Should have title 'Sign In'" do should have_title('Sign in') end
        end

        describe "Submitting to the update action -" do
          before { patch user_path(user) }
          specify "Should redirect to sign in" do expect(response).to redirect_to(signin_path) end
        end

        describe "Visiting the user index -" do
          before { visit users_path }
          it "Should have title 'Sign in'" do should have_title('Sign in') end
        end

        describe "Visiting the following page" do
          before { visit following_user_path(user) }
          it "Should have title 'Sign in'" do should have_title('Sign in') end
        end

        describe "Visiting the followers page" do
          before { visit followers_user_path(user) }
          it "Should have title 'Sign in'" do should have_title('Sign in') end
        end
      end

      describe "In the Relationships controller" do
        describe "Submitting to the create action" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "Submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }
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
