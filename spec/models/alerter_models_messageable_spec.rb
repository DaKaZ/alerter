require 'spec_helper'

describe "Alerter::Models::Messageable through User" do

  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)
  end

  it "should have a mailbox" do
    assert @entity1.mailbox
  end

  it 'should return the inbox count' do
    expect(@entity1.unread_inbox_count).to eq 0
    @entity1.send_message("short", "long", "normal")
    @entity1.send_message("short", "long", "normal")
    expect(@entity1.unread_inbox_count).to eq 2
    @entity1.receipts.first.mark_as_read
    expect(@entity1.unread_inbox_count).to eq 1
    @entity1.send_message("short", "long", "normal")
    @entity1.send_message("short", "long", "normal")
    expect(@entity1.unread_inbox_count).to eq 3
  end

  it "should be able to send a message" do
    assert @entity1.send_message("short", "long", "normal")
  end

  describe 'receipts' do
    context 'single message' do
      it "should be able to unread an owned Alerter::Receipt (mark as unread)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        expect(@receipt.is_unread?).to eq true
        @entity1.mark_as_read(@receipt)
        @entity1.mark_as_unread(@receipt)
        expect(@receipt.is_unread?).to eq true
      end

      it "should be able to read an owned Alerter::Receipt (mark as read)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        expect(@receipt.is_unread?).to eq true
        @entity1.mark_as_read(@receipt)
        expect(@receipt.is_read?).to eq true
      end

      it "should be able to undelete an owned Alerter::Receipt (mark as not deleted)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        expect(@receipt.deleted?).to eq false
        @entity1.mark_as_deleted(@receipt)
        @entity1.mark_as_not_deleted(@receipt)
        expect(@receipt.deleted?).to eq false
      end

      it "should be able to delete an owned Alerter::Receipt (mark as deleted)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        expect(@receipt.deleted?).to eq false
        @entity1.mark_as_deleted(@receipt)
        expect(@receipt.deleted?).to eq true
      end

      it "should not be able to unread a not owned Alerter::Receipt (mark as unread)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @entity1.mark_as_read(@receipt)
        expect(@receipt.is_read?).to eq true
        @entity2.mark_as_unread(@receipt) #Should not change
        expect(@receipt.is_read?).to eq true
      end

      it "should not be able to read a not owned Alerter::Receipt (mark as read)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        expect(@receipt.is_unread?).to eq true
        @entity2.mark_as_read(@receipt) #Should not change
        expect(@receipt.is_unread?).to eq true
      end

      it "should not be able to delete a not owned Alerter::Receipt (mark as deleted)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        expect(@receipt.deleted?).to eq false
        @entity2.mark_as_deleted(@receipt) #Should not change
        expect(@receipt.deleted?).to eq false
      end

      it "should not be able to undelete a not owned Alerter::Receipt (mark as not deleted)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        expect(@receipt.deleted?).to eq false
        @entity2.mark_as_deleted(@receipt)
        @entity2.mark_as_not_deleted(@receipt) #Should not change
        expect(@receipt.deleted?).to eq false
      end
    end

    context 'multiple' do
      it "should be able to unread multiple owned Alerter::Receipts (mark as unread)" do
        @receipts = [@entity1.send_message("short", "long", "normal"),
                     @entity1.send_message("short", "long", "normal"),
                     @entity2.send_message("short", "long", "normal")]

        expect(@receipts.first.is_unread?).to eq true
        expect(@receipts.second.is_unread?).to eq true
        expect(@receipts.third.is_unread?).to eq true
        @entity1.mark_as_read(@receipts)
        @entity2.mark_as_read(@receipts)
        expect(@receipts.first.is_read?).to eq true
        expect(@receipts.second.is_read?).to eq true
        expect(@receipts.third.is_read?).to eq true
        @entity1.mark_as_unread(@receipts)
        expect(@receipts.first.is_unread?).to eq true
        expect(@receipts.second.is_unread?).to eq true
        expect(@receipts.third.is_unread?).to eq false
      end


      it "should be able to read multiple owned Alerter::Receipts (mark as read)" do
        @receipts = [@entity1.send_message("short", "long", "normal"),
                     @entity1.send_message("short", "long", "normal"),
                     @entity2.send_message("short", "long", "normal")]

        expect(@receipts.first.is_unread?).to eq true
        expect(@receipts.second.is_unread?).to eq true
        expect(@receipts.third.is_unread?).to eq true
        @entity1.mark_as_read(@receipts)
        expect(@receipts.first.is_read?).to eq true
        expect(@receipts.second.is_read?).to eq true
        expect(@receipts.third.is_read?).to eq false
      end


      it "should be able to undelete multiple owned Alerter::Receipts (mark as not deleted)" do
        @receipts = [@entity1.send_message("short", "long", "normal"),
                     @entity1.send_message("short", "long", "normal"),
                     @entity2.send_message("short", "long", "normal")]

        expect(@receipts.first.deleted?).to eq false
        expect(@receipts.second.deleted?).to eq false
        expect(@receipts.third.deleted?).to eq false
        @entity1.mark_as_deleted(@receipts)
        @entity2.mark_as_deleted(@receipts)
        expect(@receipts.first.deleted?).to eq true
        expect(@receipts.second.deleted?).to eq true
        expect(@receipts.third.deleted?).to eq true
        @entity1.mark_as_not_deleted(@receipts)
        expect(@receipts.first.deleted?).to eq false
        expect(@receipts.second.deleted?).to eq false
        expect(@receipts.third.deleted?).to eq true
      end


      it "should be able to delete multiple owned Alerter::Receipts (mark as deleted)" do
        @receipts = [@entity1.send_message("short", "long", "normal"),
                     @entity1.send_message("short", "long", "normal"),
                     @entity2.send_message("short", "long", "normal")]

        expect(@receipts.first.deleted?).to eq false
        expect(@receipts.second.deleted?).to eq false
        expect(@receipts.third.deleted?).to eq false
        @entity1.mark_as_deleted(@receipts)
        expect(@receipts.first.deleted?).to eq true
        expect(@receipts.second.deleted?).to eq true
        expect(@receipts.third.deleted?).to eq false
      end
    end
  end

  describe 'messages' do
    context 'single' do
      it "should be able to unread an owned Message (mark as unread)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @entity1.mark_as_read(@receipt)
        @message = @receipt.message
        expect(@receipt.is_read?).to eq true
        @entity1.mark_as_unread(@message)
        expect(@message.receipts_for(@entity1).first.is_read?).to eq false
      end

      it "should be able to read an owned Message (mark as read)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @message = @receipt.message
        expect(@receipt.is_unread?).to eq true
        @entity1.mark_as_read(@message)
        expect(@message.receipt_for(@entity1).first.is_read?).to eq true
      end

      it "should be able to delete an owned Message (mark as deleted)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @message = @receipt.message
        expect(@receipt.deleted?).to eq false
        @entity1.mark_as_deleted(@message)
        expect(@message.receipt_for(@entity1).first.deleted?).to eq true
      end

      it "should be able to undelete an owned Message (mark as not deleted)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @message = @receipt.message
        expect(@receipt.deleted?).to eq false
        @entity1.mark_as_deleted(@message)
        expect(@message.receipt_for(@entity1).first.deleted?).to eq true
        @entity1.mark_as_not_deleted(@message)
        expect(@message.receipt_for(@entity1).first.deleted?).to eq false
      end

      it "should not be able to unread a not owned Message (mark as unread)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @entity1.mark_as_read(@receipt)
        @message = @receipt.message
        expect(@receipt.is_read?).to eq true
        @entity2.mark_as_unread(@message)
        expect(@message.receipt_for(@entity1).first.is_read?).to eq true
      end

      it "should not be able to read a not owned Message (mark as read)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @message = @receipt.message
        expect(@receipt.is_unread?).to eq true
        @entity2.mark_as_read(@message)
        expect(@message.receipt_for(@entity1).first.is_read?).to eq false
      end

      it "should not be able to delete a not owned Message (mark as deleted)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @message = @receipt.message
        expect(@receipt.deleted?).to eq false
        @entity2.mark_as_deleted(@message)
        expect(@message.receipt_for(@entity1).first.deleted?).to eq false
      end

      it "should not be able to undelete a not owned Message (mark as not deleted)" do
        @receipt = @entity1.send_message("short", "long", "normal")
        @message = @receipt.message
        expect(@receipt.deleted?).to eq false
        @entity1.mark_as_deleted(@message)
        expect(@message.receipt_for(@entity1).first.deleted?).to eq true
        @entity2.mark_as_not_deleted(@message)
        expect(@message.receipt_for(@entity1).first.deleted?).to eq true
      end
    end

    context 'multiple' do
      it "should be able to unread multiple owned Messages (mark as unread)" do
        @receipts = [@entity1.send_message("short", "long", "normal"),
                     @entity1.send_message("short", "long", "normal"),
                     @entity2.send_message("short", "long", "normal")]
        @messages = @receipts.map { |r| r.message}

        expect(@receipts.first.is_unread?).to eq true
        expect(@receipts.second.is_unread?).to eq true
        expect(@receipts.third.is_unread?).to eq true
        @entity1.mark_as_read(@messages)
        @entity2.mark_as_read(@messages)
        expect(@messages.first.receipt_for(@entity1).first.is_read?).to eq true
        expect(@messages.second.receipt_for(@entity1).first.is_read?).to eq true
        expect(@messages.third.receipt_for(@entity2).first.is_read?).to eq true
        @entity1.mark_as_unread(@messages)
        expect(@messages.first.receipt_for(@entity1).first.is_unread?).to eq true
        expect(@messages.second.receipt_for(@entity1).first.is_unread?).to eq true
        expect(@messages.third.receipt_for(@entity2).first.is_unread?).to eq false
      end


      it "should be able to read multiple owned Messages (mark as read)" do
        @receipts = [@entity1.send_message("short", "long", "normal"),
                     @entity1.send_message("short", "long", "normal"),
                     @entity2.send_message("short", "long", "normal")]
        @messages = @receipts.map { |r| r.message}

        expect(@receipts.first.is_unread?).to eq true
        expect(@receipts.second.is_unread?).to eq true
        expect(@receipts.third.is_unread?).to eq true
        @entity1.mark_as_read(@messages)
        expect(@messages.first.receipt_for(@entity1).first.is_read?).to eq true
        expect(@messages.second.receipt_for(@entity1).first.is_read?).to eq true
        expect(@messages.third.receipt_for(@entity2).first.is_read?).to eq false
      end

      it "should be able to undelete multiple owned Messages (mark as not deleted)" do
        @receipts = [@entity1.send_message("short", "long", "normal"),
                     @entity1.send_message("short", "long", "normal"),
                     @entity2.send_message("short", "long", "normal")]
        @messages = @receipts.map { |r| r.message}

        expect(@receipts.first.deleted?).to eq false
        expect(@receipts.second.deleted?).to eq false
        expect(@receipts.third.deleted?).to eq false
        @entity1.mark_as_deleted(@messages)
        @entity2.mark_as_deleted(@messages)
        expect(@messages.first.receipt_for(@entity1).first.deleted?).to eq true
        expect(@messages.second.receipt_for(@entity1).first.deleted?).to eq true
        expect(@messages.third.receipt_for(@entity2).first.deleted?).to eq true
        @entity1.mark_as_not_deleted(@messages)
        expect(@messages.first.receipt_for(@entity1).first.deleted?).to eq false
        expect(@messages.second.receipt_for(@entity1).first.deleted?).to eq false
        expect(@messages.third.receipt_for(@entity2).first.deleted?).to eq true
      end

      it "should be able to delete multiple owned Messages (mark as deleted)" do
        @receipts = [@entity1.send_message("short", "long", "normal"),
                     @entity1.send_message("short", "long", "normal"),
                     @entity2.send_message("short", "long", "normal")]
        @messages = @receipts.map { |r| r.message}

        expect(@receipts.first.deleted?).to eq false
        expect(@receipts.second.deleted?).to eq false
        expect(@receipts.third.deleted?).to eq false
        @entity1.mark_as_deleted(@messages)
        expect(@messages.first.receipt_for(@entity1).first.deleted?).to eq true
        expect(@messages.second.receipt_for(@entity1).first.deleted?).to eq true
        expect(@messages.third.receipt_for(@entity2).first.deleted?).to eq false
      end
    end
  end
end
