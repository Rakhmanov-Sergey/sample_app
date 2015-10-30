require 'spec_helper'

describe "User pages -" do

  subject { page }

  describe "Index page -" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it "Should have title 'All users'"      do should have_title('All users') end
    it "Should have 'All users' in content" do should have_content('All users') end

    describe "Agination -" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it "Should have page selector" do should have_selector('div.pagination') end

      it "Should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "Delete links -" do

      it "Should not have link 'Delete'" do should_not have_link('delete') end

      describe "As an admin user -" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it "Should have link 'Delete'" do should have_link('delete', href: user_path(User.first)) end

        it "Should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end

        it "Should not be able to delet himself" do
          should_not have_link('delete', href: user_path(admin))
        end
      end
    end
  end

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
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

    before { visit user_path(user) }

    it "Should have user name in content" do should have_content(user.name) end
    it "Should have user name in title"   do should have_title(user.name) end

    describe "Microposts -" do
      it "Should have m1 in content"                do should have_content(m1.content) end
      it "Should have m2 in content"                do should have_content(m2.content) end
      it "Should have microposts number in content" do should have_content(user.microposts.count) end
    end

    describe "Follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "Following a user" do
        before { visit user_path(other_user) }

        it "Should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "Should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "Toggling the button" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end

      describe "Unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "Should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "Should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "Toggling the button" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end
      end
    end
  end

  describe "Edit page -" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    it "Should have content 'Update your profile'" do should have_content("Update your profile") end
    it "Should have title 'Edit user'"             do should have_title("Edit user") end

    it "Should have link to change gravatar" do
      should have_link('change', href: 'http://gravatar.com/emails')
    end

    describe "With invalid information -" do
      before { click_button "Save changes" }

      it "Should have content 'Error'" do should have_content('error') end
    end

    describe "With valid information -" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it "Should have new user name in title"   do should have_title(new_name) end
      it "Should have selector 'alert-success'" do should have_selector('div.alert.alert-success') end
      it "Should have link 'Sign Out'"          do should have_link('Sign out', href: signout_path) end

      specify "Expect name to change"  do expect(user.reload.name).to  eq new_name end
      specify "Expect email to change" do expect(user.reload.email).to eq new_email end
    end
  end

  describe "Following/followers page" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "Followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it "Should have title 'Following'"    do should have_title(full_title('Following')) end
      it "Should have 'Following' in text"  do should have_selector('h3', text: 'Following') end
      it "Should have a link to other_user" do
        should have_link(other_user.name, href: user_path(other_user))
      end
    end

    describe "Followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it "Should have title 'Followers'"    do should have_title(full_title('Followers')) end
      it "Should have 'Followers' in text"  do should have_selector('h3', text: 'Followers') end
      it "Should have a link to user" do
        should have_link(user.name, href: user_path(user))
      end
    end
  end
end