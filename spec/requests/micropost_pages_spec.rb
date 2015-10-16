require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "Micropost creation" do
    before { visit root_path }

    describe "With invalid information" do

      it "Should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "Should show error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "With valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "Should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "Micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end
end