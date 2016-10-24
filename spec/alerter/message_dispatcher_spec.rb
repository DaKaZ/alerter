require 'spec_helper'

describe Alerter::MessageDispatcher do
  before(:all) do
    Rpush::Notification.destroy_all
    Rpush::App.destroy_all
  end

  subject(:instance) { described_class.new(message, recipients) }

  let(:message)   { FactoryGirl.create :message }
  let(:recipient1) { FactoryGirl.create :user_with_email_pref, email: nil  }
  let(:recipient2) { FactoryGirl.create :user_with_email_pref  }
  let(:recipient3) { FactoryGirl.create :user_with_push_pref  }
  let(:recipient4) { FactoryGirl.create :user_with_push_pref  }
  let(:recipients) { [ recipient1, recipient2, recipient3, recipient4 ] }

  describe 'call' do
    context 'supported methods' do
      before { Alerter.notification_method = %w( bad ) }
      after  { Alerter.notification_method = %w( in_app email push_notification sms twitter )}
      its(:call) { should be false }
    end

    context 'mailer wants array' do
      before { Alerter.mailer_wants_array = true  }
      after  { Alerter.mailer_wants_array = false }
      it 'sends collection' do
        expect(subject).to receive(:send_email).with([recipient1, recipient2])
        expect(subject).to receive(:send_push_alert).with(recipient3)
        expect(subject).to receive(:send_push_alert).with(recipient4)
        subject.call
      end
    end

    context 'mailer does not want array' do
      it 'sends collection' do
        expect(subject).not_to receive(:send_email).with(recipient1) #email is blank
        expect(subject).to receive(:send_email).with(recipient2)
        expect(subject).to receive(:send_push_alert).with(recipient3)
        expect(subject).to receive(:send_push_alert).with(recipient4)
        subject.call
      end
    end
  end

  describe 'send_email' do

    let(:mailer) { double 'mailer' }

    before(:each) do
      allow(subject).to receive(:mailer).and_return mailer
    end

    context 'with custom_deliver_proc' do
      let(:my_proc) { double 'proc' }

      before { Alerter.custom_email_delivery_proc = my_proc }
      after  { Alerter.custom_email_delivery_proc = nil     }
      it 'triggers proc' do
        expect(my_proc).to receive(:call).with(mailer, message, recipient1)
        subject.send :send_email, recipient1
      end
    end

    context 'without custom_deliver_proc' do
      let(:email) { double :email }

      it 'triggers standard deliver chain' do
        expect(mailer).to receive(:send_email).with(message, recipient1).and_return email
        expect(email).to receive :deliver

        subject.send :send_email, recipient1
      end
    end
  end

  describe 'send_push_notification' do

    context 'with custom_deliver_proc' do
      let(:my_proc) { double 'proc' }

      before { Alerter.custom_push_delivery_proc = my_proc }
      after  { Alerter.custom_push_delivery_proc = nil     }
      it 'triggers proc' do
        expect(my_proc).to receive(:call).with(message, recipient1)
        subject.send :send_push_alert, recipient1
      end
    end

    context 'without custom_proc' do
      it 'ios triggers standard deliver chain' do
        FactoryGirl.create(:ios_app)
        expect(recipient3).to receive(:push_data).and_return([{type: :ios, token: 'a' * 64}])
        expect {
          expect(subject.send :send_push_alert, recipient3).to eq [true]
        }.to change(Rpush::Apns::Notification, :count).by(1)
      end

      it 'android triggers standard deliver chain' do
        FactoryGirl.create(:android_app)
        expect(recipient4).to receive(:push_data).and_return([{type: :android, token: 'b' * 64}])
        expect {
          expect(subject.send :send_push_alert, recipient4).to eq [true]
        }.to change(Rpush::Gcm::Notification, :count).by(1)
      end

      it 'kindle triggers standard deliver chain' do
        FactoryGirl.create(:kindle_app)
        expect(recipient4).to receive(:push_data).and_return([{type: :kindle, token: 'b' * 64}])
        expect {
          expect(subject.send :send_push_alert, recipient4).to eq [true]
        }.to change(Rpush::Adm::Notification, :count).by(1)
      end

      it 'multiple device delivery' do
        expect(recipient4).to receive(:push_data).and_return([{type: :kindle, token: 'c' * 64}, {type: :android, token: 'b' * 64}, {type: :ios, token: 'a' * 64}])
        expect {
          expect(subject.send :send_push_alert, recipient4).to eq [true, true, true]
        }.to change(Rpush::Notification, :count).by(3)
      end

      it 'reports any failed deliveries' do
        expect(recipient4).to receive(:push_data).and_return([{type: :bad, token: 'b' * 64}, {type: :ios, token: 'a' * 64}])
        expect {
          expect(subject.send :send_push_alert, recipient4).to eq [false, true]
        }.to change(Rpush::Notification, :count).by(1)
      end

      it 'handles empty data' do
        expect(recipient4).to receive(:push_data).and_return('')
        expect {
          expect(subject.send :send_push_alert, recipient4).to eq false
        }.to change(Rpush::Notification, :count).by(0)
      end
    end
  end
end
