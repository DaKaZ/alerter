require 'spec_helper'

describe Alerter::MailDispatcher do

  subject(:instance) { described_class.new(mailable, recipients) }

  let(:mailable)   { Alerter::Message.new }
  let(:recipient1) { double 'recipient1', alerter_email: 'test@example.com'  }
  let(:recipient2) { double 'recipient2', alerter_email: 'foo@bar.com'  }
  let(:recipients) { [ recipient1, recipient2 ] }

  # TODO - need to setup and test prefrences
  
  describe "call" do
    context "no emails" do
      before { Alerter.uses_emails = false }
      after  { Alerter.uses_emails = true }
      its(:call) { should be false }
    end

    context "mailer wants array" do
      before { Alerter.mailer_wants_array = true  }
      after  { Alerter.mailer_wants_array = false }
      it 'sends collection' do
        expect(subject).to receive(:send_email).with(recipients)
        subject.call
      end
    end

    context "mailer doesnt want array" do
      it 'sends collection' do
        expect(subject).not_to receive(:send_email).with(recipient1) #email is blank
        expect(subject).to receive(:send_email).with(recipient2)
        subject.call
      end
    end
  end

  describe "send_email" do

    let(:mailer) { double 'mailer' }

    before(:each) do
      allow(subject).to receive(:mailer).and_return mailer
    end

    context "with custom_deliver_proc" do
      let(:my_proc) { double 'proc' }

      before { Alerter.custom_email_delivery_proc = my_proc }
      after  { Alerter.custom_email_delivery_proc = nil     }
      it "triggers proc" do
        expect(my_proc).to receive(:call).with(mailer, mailable, recipient1)
        subject.send :send_email, recipient1
      end
    end

    context "without custom_deliver_proc" do
      let(:email) { double :email }

      it "triggers standard deliver chain" do
        expect(mailer).to receive(:send_email).with(mailable, recipient1).and_return email
        expect(email).to receive :deliver

        subject.send :send_email, recipient1
      end
    end
  end

  describe "send_push_notification" do

    pending 'test push notifications'
    # let(:mailer) { double 'mailer' }
    #
    # before(:each) do
    #   allow(subject).to receive(:mailer).and_return mailer
    # end
    #
    # context "with custom_deliver_proc" do
    #   let(:my_proc) { double 'proc' }
    #
    #   before { Alerter.custom_deliver_proc = my_proc }
    #   after  { Alerter.custom_deliver_proc = nil     }
    #   it "triggers proc" do
    #     expect(my_proc).to receive(:call).with(mailer, mailable, recipient1)
    #     subject.send :send_email, recipient1
    #   end
    # end
    #
    # context "without custom_deliver_proc" do
    #   let(:email) { double :email }
    #
    #   it "triggers standard deliver chain" do
    #     expect(mailer).to receive(:send_email).with(mailable, recipient1).and_return email
    #     expect(email).to receive :deliver
    #
    #     subject.send :send_email, recipient1
    #   end
    # end
  end


end
