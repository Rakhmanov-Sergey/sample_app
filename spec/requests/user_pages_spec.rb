require 'spec_helper'

describe "User pages -" do

  subject { page }

  describe "Index page -" do
    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
      FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
      visit users_path
    end

    it "Should have title 'All users'" do should have_title('All users') end
    it "Should have 'All users' in content" do should have_content('All users') end

    it "Should list each user" do
      User.all.each do |user|
        expect(page).to have_selector('li', text: user.name)
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
    before { visit user_path(user) }

    let(:user) { FactoryGirl.create(:user) }
    let(:name) {user.name}

    it "Should have user name in content " do should have_content(name) end
    it "Should have user name in title "   do should have_title(name) end
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
end