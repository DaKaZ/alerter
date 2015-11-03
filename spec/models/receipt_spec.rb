require 'spec_helper'

describe Alerter::Receipt do

  before do
    @entity1 = FactoryGirl.create(:user)
    @mail1 = @entity1.send_message("short","long","info")
  end

  it "should belong to a message" do
    assert @mail1.message
  end

  it "should be able to be marked as unread" do
    @mail1.mark_as_read
    expect(@mail1.is_read).to be true
    @mail1.mark_as_unread
    expect(@mail1.is_read).to be false
  end

  it "should be included in unread search" do
    @mail1.mark_as_read
    expect(Alerter::Receipt.is_read).to include @mail1
  end

  it "should be able to be marked as read" do
    @mail1.mark_as_read
    expect(@mail1.is_read).to be true
    @mail1.mark_as_unread
    @mail1.mark_as_read
    expect(@mail1.is_read).to be true
  end

  it "should be included in read search" do
    expect(Alerter::Receipt.is_unread).to include @mail1
  end

  it "should be able to be marked as deleted" do
    expect(@mail1.deleted).to be false
    @mail1.mark_as_deleted
    expect(@mail1.deleted).to be true
  end

  it "should be able to be marked as not deleted" do
    @mail1.mark_as_deleted
    expect(@mail1.deleted).to be true
    @mail1.mark_as_not_deleted
    expect(@mail1.deleted).to be false
  end

  context "STI models" do
    before do
      @entity2 = FactoryGirl.create(:user)
      @mail2 = @entity2.send_message("short","long","info")
    end

    it "should refer to the correct base class" do
      expect(@mail2.receiver_type).to eq @entity2.class.base_class.to_s
    end
  end
end
