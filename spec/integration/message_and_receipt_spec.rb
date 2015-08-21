require 'spec_helper'

describe "Messages And Alerter::Receipts", type: :integration do

  describe "two equal entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:user)
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@entity2,"short","long")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.short_msg.eql?"short"
        assert @message1.long_msg.eql?"long"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Alerter::Receipt.recipient(@entity1).message(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Alerter::Receipt.recipient(@entity2).notification(@message1).first
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

  describe "two different entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:duck)
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@entity2,"short","long")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.short_msg.eql?"short"
        assert @message1.long_msg.eql?"long"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Alerter::Receipt.recipient(@entity1).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Alerter::Receipt.recipient(@entity2).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
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

  describe "three equal entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:user)
      @entity3 = FactoryGirl.create(:user)
      @recipients = Array.new
      @recipients << @entity2
      @recipients << @entity3
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@recipients,"short","long")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.short_msg.eql?"short"
        assert @message1.long_msg.eql?"long"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Alerter::Receipt.recipient(@entity1).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mails
        @recipients.each do |receiver|
          mail = Alerter::Receipt.recipient(receiver).notification(@message1).first
          assert mail
          if mail
            expect(mail.is_read).to be false
            expect(mail.trashed).to be false
            expect(mail.mailbox_type).to eq "inbox"
          end
        end
      end

      it "should have the correct recipients" do
        recipients = @message1.recipients
        expect(recipients.count).to eq 3
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
        expect(recipients.count(@entity3)).to eq 1
      end

    end

  end

  describe "three different entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:duck)
      @entity3 = FactoryGirl.create(:cylon)
      @recipients = Array.new
      @recipients << @entity2
      @recipients << @entity3
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@recipients,"short","long")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.short_msg.eql?"short"
        assert @message1.long_msg.eql?"long"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Alerter::Receipt.recipient(@entity1).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mails
        @recipients.each do |receiver|
          mail = Alerter::Receipt.recipient(receiver).notification(@message1).first
          assert mail
          if mail
            expect(mail.is_read).to be false
            expect(mail.trashed).to be false
            expect(mail.mailbox_type).to eq "inbox"
          end
        end
      end

      it "should have the correct recipients" do
        recipients = @message1.recipients
        expect(recipients.count).to eq 3
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
        expect(recipients.count(@entity3)).to eq 1
      end

    end

  end

end
