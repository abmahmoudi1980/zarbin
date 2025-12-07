require 'rails_helper'

RSpec.describe SmsOtpService, type: :service do
  describe '#send_otp' do
    let(:mobile_number) { '09123456789' }
    let(:service) { SmsOtpService.new }

    before do
      allow(Net::HTTP).to receive(:post_form).and_return(double(body: '{"result":{"status":200}}'))
    end

    it 'generates and sends OTP code' do
      allow(service).to receive(:call_kavenegar_api).and_return(true)

      otp_verification = service.send_otp(mobile_number)

      expect(otp_verification).to be_persisted
      expect(otp_verification.mobile_number).to eq(mobile_number)
      expect(otp_verification.otp_code).to match(/^\d{6}$/)
    end

    it 'OTP expires in 10 minutes' do
      allow(service).to receive(:call_kavenegar_api).and_return(true)

      otp_verification = service.send_otp(mobile_number)

      expect(otp_verification.expires_at).to be_within(5.seconds).of(10.minutes.from_now)
    end

    it 'invalidates previous OTP for the same number' do
      old_otp = create(:otp_verification, mobile_number: mobile_number)
      
      allow(service).to receive(:call_kavenegar_api).and_return(true)
      new_otp = service.send_otp(mobile_number)

      old_otp.reload
      expect(old_otp.is_used).to be true
      expect(new_otp.is_used).to be false
    end

    it 'calls Kavenegar API with correct parameters' do
      expect(service).to receive(:call_kavenegar_api).with(
        phone: mobile_number,
        otp: anything,
        template_name: 'zarbin_otp'
      ).and_return(true)

      service.send_otp(mobile_number)
    end

    context 'when SMS sending fails' do
      it 'raises error when API call fails' do
        allow(service).to receive(:call_kavenegar_api).and_return(false)

        expect {
          service.send_otp(mobile_number)
        }.to raise_error(SmsOtpService::SendError)
      end
    end
  end

  describe '#verify_otp' do
    let(:mobile_number) { '09123456789' }
    let(:service) { SmsOtpService.new }

    context 'with valid OTP' do
      it 'returns true and marks OTP as used' do
        otp = create(:otp_verification, mobile_number: mobile_number, otp_code: '123456')

        result = service.verify_otp(mobile_number, '123456')

        expect(result).to be true
        expect(otp.reload.is_used).to be true
      end
    end

    context 'with invalid OTP' do
      it 'returns false for wrong code' do
        create(:otp_verification, mobile_number: mobile_number, otp_code: '123456')

        result = service.verify_otp(mobile_number, '000000')

        expect(result).to be false
      end

      it 'returns false for expired OTP' do
        create(:otp_verification, 
          mobile_number: mobile_number, 
          otp_code: '123456',
          expires_at: 15.minutes.ago
        )

        result = service.verify_otp(mobile_number, '123456')

        expect(result).to be false
      end

      it 'returns false for already used OTP' do
        create(:otp_verification, 
          mobile_number: mobile_number, 
          otp_code: '123456',
          is_used: true
        )

        result = service.verify_otp(mobile_number, '123456')

        expect(result).to be false
      end

      it 'returns false for non-existent OTP' do
        result = service.verify_otp(mobile_number, '123456')

        expect(result).to be false
      end
    end
  end

  describe '#generate_otp' do
    let(:service) { SmsOtpService.new }

    it 'generates 6-digit OTP' do
      otp = service.generate_otp

      expect(otp).to match(/^\d{6}$/)
    end

    it 'generates random OTPs' do
      otp1 = service.generate_otp
      otp2 = service.generate_otp

      expect(otp1).not_to eq(otp2)
    end
  end
end
