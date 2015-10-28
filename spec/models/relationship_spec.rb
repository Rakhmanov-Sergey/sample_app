require 'spec_helper'

describe Relationship do
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  it "Should be valid" do should be_valid end

  describe "Follower methods" do
    it "Should respond to follower" do should respond_to(:follower) end
    it "Should respond to followed" do should respond_to(:followed) end

    describe "Should have right follower and following" do
      its(:follower) { should eq follower }
      its(:followed) { should eq followed }
    end
  end

  describe "When followed id is not present" do
    before { relationship.followed_id = nil }
    it "Should not be valid" do should_not be_valid end
  end

  describe "When follower id is not present" do
    before { relationship.follower_id = nil }
    it "Should not be valid" do should_not be_valid end
  end
end
