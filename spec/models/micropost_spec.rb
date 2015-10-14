require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.build(content: "Lorem ipsum") }

  subject { @micropost }

  it "Should respond to content" do should respond_to(:content) end
  it "Should respond to user id" do should respond_to(:user_id) end
  it "Should respond to user"    do should respond_to(:user) end

  it "Should be valid" do should be_valid end

  describe "Its user should equals user" do
    its(:user) { should eq user }
  end

  describe "When user_id is not present -" do
    before { @micropost.user_id = nil }
    it "Should not be valid" do should_not be_valid end
  end

  describe "With blank content -" do
    before { @micropost.content = " " }
    it "Should not be valid" do should_not be_valid end
  end

  describe "With content that is too long -" do
    before { @micropost.content = "a" * 141 }
    it "Should not be valid" do should_not be_valid end
  end
end
