require 'spec_helper'
require 'switch_user/user_loader'

class User
  def self.find_by_id(id)
  end
end

describe SwitchUser::UserLoader do
  let(:user) { stub(:user) }

  it "raises an exception if we are passed an invalid scope" do
    expect { SwitchUser::UserLoader.new("useeer", 1) }.to raise_error(SwitchUser::InvalidScope)
  end

  describe ".user" do
    before do
      SwitchUser.available_users_identifiers = {:user => :id}
      User.stub(:find_by_id).with("1").and_return(user)
    end
    it "can be loaded from a scope and identifier" do
      loaded_user = SwitchUser::UserLoader.prepare("user","1").user

      loaded_user.should == user
    end
    it "can be loaded by a passing an unprocessed scope identifier" do
      loaded_user = SwitchUser::UserLoader.prepare(:scope_identifier => "user_1").user

      loaded_user.should == user
    end
    it "raises an error for an invalid scope" do
      expect {
        loaded_user = SwitchUser::UserLoader.prepare(nil, "1")
      }.to raise_error(SwitchUser::InvalidScope)
    end
  end

  it "returns a user" do
    User.stub(:find_by_id).with(1).and_return(user)

    loader = SwitchUser::UserLoader.new("user", 1)

    loader.user.should == user
  end

  it "returns nil if no user is found" do
    loader = SwitchUser::UserLoader.new("user", 2)
    loader.user.should == nil
  end

  it "loads a user with an alternate identifier column" do
    User.stub(:find_by_email).with(2).and_return(user)
    SwitchUser.available_users_identifiers = {:user => :email}

    loader = SwitchUser::UserLoader.new("user", 2)
    loader.user.should == user
  end
end
