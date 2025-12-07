require 'rails_helper'

RSpec.describe AuthService, type: :service do
  describe '#generate_token' do
    let(:user) { create(:user, account_status: :active) }
    let(:service) { AuthService.new }

    it 'generates valid JWT token' do
      token = service.generate_token(user)

      expect(token).to be_present
      expect(token).to be_a(String)
    end

    it 'includes user ID in token payload' do
      token = service.generate_token(user)
      decoded = JWT.decode(token, Rails.application.secrets.jwt_secret, algorithm: 'HS256')
      payload = decoded.first

      expect(payload['user_id']).to eq(user.id)
    end

    it 'includes mobile_number in token payload' do
      token = service.generate_token(user)
      decoded = JWT.decode(token, Rails.application.secrets.jwt_secret, algorithm: 'HS256')
      payload = decoded.first

      expect(payload['mobile_number']).to eq(user.mobile_number)
    end

    it 'sets expiration to 7 days from now' do
      token = service.generate_token(user)
      decoded = JWT.decode(token, Rails.application.secrets.jwt_secret, algorithm: 'HS256')
      payload = decoded.first

      exp_time = Time.at(payload['exp'])
      now = Time.now

      expect(exp_time).to be_within(5.seconds).of(7.days.from_now)
    end

    it 'is different for different users' do
      user1 = create(:user, account_status: :active)
      user2 = create(:user, account_status: :active)

      token1 = service.generate_token(user1)
      token2 = service.generate_token(user2)

      expect(token1).not_to eq(token2)
    end
  end

  describe '#decode_token' do
    let(:user) { create(:user, account_status: :active) }
    let(:service) { AuthService.new }

    context 'with valid token' do
      it 'returns payload hash' do
        token = service.generate_token(user)
        payload = service.decode_token(token)

        expect(payload).to be_a(Hash)
        expect(payload['user_id']).to eq(user.id)
      end

      it 'includes user data in payload' do
        token = service.generate_token(user)
        payload = service.decode_token(token)

        expect(payload['mobile_number']).to eq(user.mobile_number)
      end
    end

    context 'with invalid token' do
      it 'raises error for malformed token' do
        expect {
          service.decode_token('invalid.token.here')
        }.to raise_error(AuthService::InvalidTokenError)
      end

      it 'raises error for expired token' do
        token = service.generate_token(user)
        
        travel_to(8.days.from_now) do
          expect {
            service.decode_token(token)
          }.to raise_error(AuthService::TokenExpiredError)
        end
      end

      it 'raises error for tampered token' do
        token = service.generate_token(user)
        tampered = token[0..-5] + 'xxxxx'

        expect {
          service.decode_token(tampered)
        }.to raise_error(AuthService::InvalidTokenError)
      end
    end

    context 'with nil token' do
      it 'raises error' do
        expect {
          service.decode_token(nil)
        }.to raise_error(AuthService::InvalidTokenError)
      end
    end
  end

  describe '#refresh_token' do
    let(:user) { create(:user, account_status: :active) }
    let(:service) { AuthService.new }

    context 'with valid existing token' do
      it 'generates new token' do
        old_token = service.generate_token(user)
        
        travel_to(1.day.from_now) do
          new_token = service.refresh_token(old_token)

          expect(new_token).to be_present
          expect(new_token).not_to eq(old_token)
        end
      end

      it 'preserves user ID in new token' do
        old_token = service.generate_token(user)
        
        travel_to(1.day.from_now) do
          new_token = service.refresh_token(old_token)
          payload = service.decode_token(new_token)

          expect(payload['user_id']).to eq(user.id)
        end
      end
    end

    context 'with expired token' do
      it 'raises error' do
        token = service.generate_token(user)
        
        travel_to(8.days.from_now) do
          expect {
            service.refresh_token(token)
          }.to raise_error(AuthService::TokenExpiredError)
        end
      end
    end
  end

  describe '#token_info' do
    let(:user) { create(:user, account_status: :active) }
    let(:service) { AuthService.new }

    it 'returns token info hash' do
      token = service.generate_token(user)
      info = service.token_info(token)

      expect(info).to be_a(Hash)
      expect(info['token']).to eq(token)
      expect(info['expires_in']).to be_present
      expect(info['expires_at']).to be_present
    end

    it 'includes correct expiration info' do
      token = service.generate_token(user)
      info = service.token_info(token)

      expires_at = Time.parse(info['expires_at'])
      now = Time.now

      expect(expires_at).to be_within(5.seconds).of(7.days.from_now)
    end
  end
end
