require 'spec_helper'

describe "User -" do

  before { @user = User.new(name: "Example User", email: "user@example.com",
                            password: "foobar", password_confirmation: "foobar") }

  subject { @user }

  it "Should respond to name"                 do should respond_to(:name) end
  it "Should respond to email"                do should respond_to(:email) end
  it "Should respond to password_digest"      do should respond_to(:password_digest) end
  it "Should respond to password"             do should respond_to(:password) end
  it "Should respond to pasword_confirmation" do should respond_to(:password_confirmation) end
  it "Should respond to authenticate"         do should respond_to(:authenticate) end
  it "Should respond to remember_token"       do should respond_to(:remember_token) end
  it "Should respond to admin"                do should respond_to(:admin) end
  it "Should respond to microposts"           do should respond_to(:microposts) end
  it "Should respond to feed"                 do should respond_to(:feed) end
  it "Should respond to relationships"        do should respond_to(:relationships) end
  it "Should respond to followed user"        do should respond_to(:followed_users) end
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it "Should respond to following?"           do should respond_to(:following?) end
  it "Should respond to follow!"              do should respond_to(:follow!) end
  it "Should respond to unfollow!"            do should respond_to(:unfollow!) end
  it "Should be valid"                        do should be_valid end
  it "Should not be admin"                    do should_not be_admin end

  describe "With admin attribute set to 'true' -" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it "Should be admin" do should be_admin end
  end

  describe "When name is not present -" do
    before { @user.name = " " }
    it "Should not be valid" do should_not be_valid end
  end

  describe "When email is not present -" do
    before { @user.email = " " }
    it "Should not be valid" do should_not be_valid end
  end

  describe "When name is too long -" do
    before { @user.name = "a" * 51 }
    it "Should not be valid" do should_not be_valid end
  end

  describe "When email format is invalid -" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "When email format is valid -" do
    it "Should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "When email address is already taken -" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it "Should not be valid" do should_not be_valid end
  end

  describe "When email address is in uppercase -" do
    before { @user.email = "UPPERCASE@MAIL.COM" }
    let(:mixed_case_email) {@user.email}

    it "Should be transformed to downcase" do
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end

  end

  describe "When password is not present -" do
    before { @user.password = @user.password_confirmation = " " }
    it "Should not be valid" do should_not be_valid end
  end

  describe "When password doesn't match confirmation -" do
    before { @user.password_confirmation = "mismatch" }
    it "Should not be valid" do should_not be_valid end
  end

  describe "When password is too short -" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it "Should not be valid" do should_not be_valid end
  end

  describe "Return value of authenticate method -" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "With valid password -" do
      it "Should be user" do should eq found_user.authenticate(@user.password) end
    end

    describe "With invalid password -" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it "Should not be user" do should_not eq user_for_invalid_password end
      it "Should be null" do expect(user_for_invalid_password).to be_false end
    end
  end

  describe "Remember token -" do
    before { @user.save }
    it "Should not be blank" do expect(@user.remember_token).not_to be_blank end
  end

  describe "Micropost associations -" do
    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "Should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "Should destroy associated microposts" do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "Status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "Following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it "Should be following other_user" do should be_following(other_user) end

    describe "other_user should be in user.followed_uses array" do
      its(:followed_users) { should include(other_user) }
    end

    describe "And unfollowing" do
      before { @user.unfollow!(other_user) }

      it "Should not be follow other_user" do should_not be_following(other_user) end

      describe "other_user should not be in user.followed_uses array" do
        its(:followed_users) { should_not include(other_user) }
      end
    end

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end
  end
end