require 'spec_helper'

describe "Messages And Alerter::Receipts", type: :integration do

  describe "two equal entities" do
    before do
      @entity1 = FactoryGirl.create :user
      @entity2 = FactoryGirl.create :user
    end

    describe "message sending" do

      before do
        @receipts = Alerter::Message.message_all([@entity1,@entity2],"short", "long", "normal")
        @message1 = @receipts.first.message
      end

      it "should create proper message" do
        assert @message1.short_msg.eql?"short"
        assert @message1.long_msg.eql?"long"
      end

      it "should create proper mails" do
        #Receiver
        mail = Alerter::Receipt.recipient(@entity1).where(message: @message1).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message1.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

    end
  end
end
