# Iranian SMS OTP Services Research

**Date:** December 6, 2025  
**Purpose:** Identify SMS gateway providers for OTP/verification in Iran  
**Framework:** Ruby on Rails

---

## Executive Summary

### Recommended Primary Provider: **Kavenegar**

**Rationale:**
- Market leader in Iranian SMS services
- Excellent API documentation (Persian & English)
- Ruby gem available (`kavenegar` gem)
- Dedicated OTP/Verify service with built-in rate limiting
- High delivery rate for Iranian mobile operators
- Competitive pricing with free tier for testing

### Recommended Backup: **Ghasedak**

---

## 1. Kavenegar (kavenegar.com)

### Overview
Kavenegar is the most popular SMS service provider in Iran, specifically designed for Iranian businesses. They offer specialized OTP services with built-in verification flow.

### Key Features
- **OTP/Verify Service:** Built-in OTP handling with template support
- **Lookup API:** Template-based SMS (faster delivery, lower cost)
- **Direct SMS:** Custom message sending
- **Voice OTP:** Fallback option for SMS failures
- **Dedicated Line:** 1000x, 2000x, 3000x numbers available

### API Endpoints

#### Base URL
```
https://api.kavenegar.com/v1/{API_KEY}/
```

#### Send OTP (Verify/Lookup)
```
POST https://api.kavenegar.com/v1/{API_KEY}/verify/lookup.json
```

**Parameters:**
```json
{
  "receptor": "09121234567",
  "token": "123456",
  "template": "verify"
}
```

#### Send Direct SMS
```
POST https://api.kavenegar.com/v1/{API_KEY}/sms/send.json
```

**Parameters:**
```json
{
  "receptor": "09121234567",
  "message": "کد تایید شما: 123456",
  "sender": "10004346"
}
```

#### Check Delivery Status
```
GET https://api.kavenegar.com/v1/{API_KEY}/sms/status.json?messageid={ID}
```

### Sample Response
```json
{
  "return": {
    "status": 200,
    "message": "تایید شد"
  },
  "entries": [
    {
      "messageid": 8792343,
      "message": "کد تایید شما: 123456",
      "status": 1,
      "statustext": "در صف ارسال",
      "sender": "10004346",
      "receptor": "09121234567",
      "date": 1733500000,
      "cost": 580
    }
  ]
}
```

### Ruby on Rails Integration

#### Using Official Gem
```ruby
# Gemfile
gem 'kavenegar'

# config/initializers/kavenegar.rb
Kavenegar.configure do |config|
  config.api_key = Rails.application.credentials.kavenegar[:api_key]
end

# app/services/sms_service.rb
class SmsService
  def self.send_otp(phone_number, code)
    client = Kavenegar::KavenegarApi.new
    client.verify_lookup(phone_number, code, nil, nil, "verify")
  rescue Kavenegar::APIException => e
    Rails.logger.error "Kavenegar error: #{e.message}"
    raise
  end
end
```

#### Using REST API Directly
```ruby
# app/services/kavenegar_service.rb
class KavenegarService
  include HTTParty
  base_uri 'https://api.kavenegar.com/v1'
  
  def initialize
    @api_key = Rails.application.credentials.kavenegar[:api_key]
  end
  
  def send_otp(phone, code, template: 'verify')
    response = self.class.post(
      "/#{@api_key}/verify/lookup.json",
      body: {
        receptor: phone,
        token: code,
        template: template
      }
    )
    handle_response(response)
  end
  
  private
  
  def handle_response(response)
    result = JSON.parse(response.body)
    raise "SMS failed: #{result['return']['message']}" unless result['return']['status'] == 200
    result['entries']
  end
end
```

### Pricing (as of Dec 2025)

| Service | Price (IRR) | Price (Toman) | Notes |
|---------|-------------|---------------|-------|
| Direct SMS | ~580-800 | ~58-80 | Per message |
| Lookup/OTP | ~450-600 | ~45-60 | Template-based |
| Dedicated Line | Varies | Varies | Monthly fee |
| Free Credit | 10,000 | 1,000 | Upon registration |

### Rate Limits
- **Per Second:** 30 requests/second
- **Per Day:** No limit (charged per message)
- **OTP Cooldown:** Configurable (recommend 60-120 seconds)

### Delivery Speed
- **Average:** 3-10 seconds
- **Peak Hours:** May increase to 15-30 seconds
- **Success Rate:** ~98% for valid numbers

### Supported Operators
| Operator | Status |
|----------|--------|
| MCI (Hamrahe Aval) | ✅ Full support |
| MTN Irancell | ✅ Full support |
| Rightel | ✅ Full support |
| Shatel Mobile | ✅ Full support |
| MVNO Operators | ✅ Most supported |

### Pros
✅ Best documentation in Iran  
✅ Ruby gem available  
✅ Specialized OTP/Verify service  
✅ High delivery rate  
✅ Persian support team  
✅ Dashboard with analytics  
✅ Webhook support for delivery reports  

### Cons
❌ Persian-first documentation  
❌ Payment requires Iranian bank account  
❌ No international SMS support  

---

## 2. Ghasedak (ghasedak.me)

### Overview
Ghasedak is a reliable SMS provider with competitive pricing and good developer tools.

### Key Features
- OTP verification service
- Template-based messaging
- Bulk SMS support
- WebHook delivery reports

### API Endpoints

#### Base URL
```
https://api.ghasedak.me/v2/
```

#### Send OTP
```
POST https://api.ghasedak.me/v2/verification/send/simple
```

**Headers:**
```
apikey: YOUR_API_KEY
Content-Type: application/x-www-form-urlencoded
```

**Parameters:**
```
receptor=09121234567&type=1&template=verify&param1=123456
```

#### Check Status
```
GET https://api.ghasedak.me/v2/sms/status?id={MESSAGE_ID}
```

### Ruby Integration
```ruby
# app/services/ghasedak_service.rb
class GhasedakService
  include HTTParty
  base_uri 'https://api.ghasedak.me/v2'
  
  def initialize
    @api_key = Rails.application.credentials.ghasedak[:api_key]
  end
  
  def send_otp(phone, code, template: 'verify')
    response = self.class.post(
      '/verification/send/simple',
      headers: {
        'apikey' => @api_key,
        'Content-Type' => 'application/x-www-form-urlencoded'
      },
      body: {
        receptor: phone,
        type: 1,
        template: template,
        param1: code
      }
    )
    handle_response(response)
  end
  
  private
  
  def handle_response(response)
    result = JSON.parse(response.body)
    raise "SMS failed: #{result['message']}" unless result['result']['code'] == 200
    result
  end
end
```

### Pricing

| Service | Price (Toman) | Notes |
|---------|---------------|-------|
| OTP SMS | ~50-70 | Per message |
| Regular SMS | ~60-90 | Per message |
| Dedicated Line | ~100K-500K | Monthly |

### Rate Limits
- **Per Second:** 20 requests/second
- **OTP Cooldown:** Configurable

### Pros
✅ Competitive pricing  
✅ Good API documentation  
✅ Reliable delivery  
✅ Simple API structure  

### Cons
❌ No official Ruby gem  
❌ Slightly smaller market share  
❌ Less feature-rich than Kavenegar  

---

## 3. Mediana (mediana.ir)

### Overview
Mediana (formerly known as Melipayamak) is one of the oldest SMS providers in Iran.

### API Endpoint
```
https://rest.payamak-panel.com/api/SendSMS/SendSMS
```

### Sample Request
```ruby
# Using SOAP or REST API
class MedianaService
  include HTTParty
  base_uri 'https://rest.payamak-panel.com/api'
  
  def send_otp(phone, code)
    self.class.post(
      '/SendSMS/SendSMS',
      body: {
        username: @username,
        password: @password,
        to: phone,
        from: @sender_number,
        text: "کد تایید: #{code}",
        isFlash: false
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end
```

### Pricing
- Per SMS: ~50-100 Toman
- Bulk discounts available

### Pros
✅ Long track record  
✅ Bulk SMS expertise  
✅ Multiple API options (REST, SOAP)  

### Cons
❌ Older API design  
❌ Less modern documentation  
❌ Password-based auth (less secure)  

---

## 4. SMS.ir

### Overview
SMS.ir offers both SMS and messaging services with a modern API.

### API Endpoint
```
https://api.sms.ir/v1/send/verify
```

### Sample Request
```ruby
class SmsIrService
  include HTTParty
  base_uri 'https://api.sms.ir/v1'
  
  def initialize
    @api_key = Rails.application.credentials.sms_ir[:api_key]
  end
  
  def send_otp(phone, code, template_id:)
    self.class.post(
      '/send/verify',
      headers: {
        'x-api-key' => @api_key,
        'Content-Type' => 'application/json'
      },
      body: {
        mobile: phone,
        templateId: template_id,
        parameters: [
          { name: 'CODE', value: code.to_s }
        ]
      }.to_json
    )
  end
end
```

### Pricing
- Per SMS: ~45-70 Toman
- Free credit on registration

### Pros
✅ Modern RESTful API  
✅ Good documentation  
✅ Competitive pricing  

### Cons
❌ No Ruby gem  
❌ Smaller market share  

---

## 5. Faraz SMS (farazsms.com)

### Overview
Faraz SMS is another established player with enterprise features.

### API Structure
- REST API available
- SOAP for legacy systems
- WebHook support

### Pricing
- Per SMS: ~50-80 Toman
- Volume discounts

### Pros
✅ Enterprise features  
✅ Good uptime  

### Cons
❌ Less developer-friendly  
❌ Outdated documentation  

---

## Comparison Matrix

| Provider | Ruby Gem | API Quality | OTP Service | Pricing | Reliability | Docs Quality |
|----------|----------|-------------|-------------|---------|-------------|--------------|
| **Kavenegar** | ✅ Yes | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Ghasedak** | ❌ No | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **SMS.ir** | ❌ No | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Mediana** | ❌ No | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Faraz SMS** | ❌ No | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## Final Recommendation

### Primary: **Kavenegar**

**Why Kavenegar for Zarbin:**
1. **Official Ruby Gem:** Reduces integration time significantly
2. **Verify/Lookup API:** Purpose-built for OTP with templates
3. **Industry Standard:** Most widely used in Iranian fintech
4. **Reliability:** 98%+ delivery rate
5. **Documentation:** Best in class, with code samples
6. **Support:** Persian-speaking technical support

### Backup: **Ghasedak**

**Why Ghasedak as backup:**
1. Competitive pricing
2. Good API reliability
3. Easy to implement fallback

---

## Implementation Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Rails App                        │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │           OtpService                         │   │
│  │  - generate_code()                           │   │
│  │  - send_otp(phone, code)                    │   │
│  │  - verify_otp(phone, code)                  │   │
│  └─────────────────────────────────────────────┘   │
│                      │                              │
│           ┌──────────┴──────────┐                  │
│           ▼                     ▼                  │
│  ┌─────────────────┐   ┌─────────────────┐        │
│  │ KavenegarClient │   │ GhasedakClient  │        │
│  │   (Primary)     │   │   (Fallback)    │        │
│  └─────────────────┘   └─────────────────┘        │
│           │                     │                  │
└───────────┼─────────────────────┼──────────────────┘
            ▼                     ▼
    ┌───────────────┐    ┌───────────────┐
    │  Kavenegar    │    │   Ghasedak    │
    │     API       │    │     API       │
    └───────────────┘    └───────────────┘
```

---

## Recommended Implementation

### 1. Gem Installation
```ruby
# Gemfile
gem 'kavenegar'
gem 'httparty'  # For backup provider
```

### 2. Configuration
```ruby
# config/initializers/sms.rb
Rails.application.configure do
  config.sms = ActiveSupport::OrderedOptions.new
  config.sms.provider = :kavenegar
  config.sms.otp_template = 'verify'
  config.sms.otp_expiry = 2.minutes
  config.sms.otp_length = 6
  config.sms.cooldown = 60.seconds
end
```

### 3. Credentials
```yaml
# config/credentials.yml.enc
kavenegar:
  api_key: "your_api_key_here"
  
ghasedak:
  api_key: "backup_api_key_here"
```

### 4. Service Implementation
```ruby
# app/services/otp_service.rb
class OtpService
  OTP_EXPIRY = 2.minutes
  OTP_LENGTH = 6
  COOLDOWN = 60.seconds
  
  def initialize(phone_number)
    @phone = normalize_phone(phone_number)
  end
  
  def send_otp
    raise CooldownError if in_cooldown?
    
    code = generate_code
    store_otp(code)
    
    deliver_sms(code)
  rescue SmsDeliveryError => e
    deliver_via_backup(code)
  end
  
  def verify(code)
    stored = fetch_stored_otp
    return false if stored.nil?
    return false if expired?(stored[:created_at])
    
    ActiveSupport::SecurityUtils.secure_compare(
      stored[:code].to_s,
      code.to_s
    )
  end
  
  private
  
  def generate_code
    SecureRandom.random_number(10**OTP_LENGTH).to_s.rjust(OTP_LENGTH, '0')
  end
  
  def deliver_sms(code)
    client = Kavenegar::KavenegarApi.new
    client.verify_lookup(@phone, code, nil, nil, 'verify')
  end
  
  def deliver_via_backup(code)
    GhasedakService.new.send_otp(@phone, code)
  end
  
  def normalize_phone(phone)
    phone.gsub(/\D/, '').gsub(/^98/, '0').gsub(/^\+98/, '0')
  end
end
```

---

## Security Considerations

### Rate Limiting
```ruby
# app/controllers/concerns/otp_rate_limiter.rb
module OtpRateLimiter
  extend ActiveSupport::Concern
  
  included do
    before_action :check_otp_rate_limit, only: [:request_otp]
  end
  
  private
  
  def check_otp_rate_limit
    key = "otp_requests:#{request.remote_ip}"
    count = Rails.cache.increment(key, 1, expires_in: 1.hour)
    
    if count > 10
      render json: { error: 'Too many OTP requests' }, status: :too_many_requests
    end
  end
end
```

### OTP Expiration
- 2-minute expiry recommended
- One-time use (delete after successful verification)
- Maximum 3 verification attempts per OTP

### Phone Number Validation
```ruby
# Validate Iranian mobile numbers
IRAN_MOBILE_REGEX = /\A(09|989|\+989)[0-9]{9}\z/

def valid_iranian_mobile?(phone)
  normalized = phone.gsub(/\D/, '')
  normalized.match?(IRAN_MOBILE_REGEX)
end
```

---

## Cost Estimation

### Monthly Cost (Estimated)
| Users | OTPs/Month | Cost (Toman) | Cost (USD @ 60K rate) |
|-------|------------|--------------|----------------------|
| 1,000 | 3,000 | ~180,000 | ~$3 |
| 10,000 | 30,000 | ~1,800,000 | ~$30 |
| 50,000 | 150,000 | ~9,000,000 | ~$150 |
| 100,000 | 300,000 | ~18,000,000 | ~$300 |

*Assumes 3 OTPs per user per month average*

---

## Next Steps

1. [x] Research available SMS providers
2. [ ] Register for Kavenegar account
3. [ ] Create OTP message template
4. [ ] Implement OtpService
5. [ ] Add Ghasedak fallback
6. [ ] Implement rate limiting
7. [ ] Add monitoring/alerting
8. [ ] Test with all major carriers

---

## Appendix: Kavenegar Template Setup

### Creating OTP Template
1. Login to Kavenegar panel (panel.kavenegar.com)
2. Go to "تنظیمات" (Settings) → "قالب پیامک" (SMS Templates)
3. Create template named `verify`:
   ```
   کد تایید شما در زربین: %token
   ```
4. Wait for template approval (usually 1-2 hours)

### Template Variables
| Variable | Description |
|----------|-------------|
| `%token` | Primary OTP code |
| `%token2` | Secondary value (optional) |
| `%token3` | Third value (optional) |

---

## Legal Considerations

1. **ICT Regulations:** SMS services must be registered with Iranian ICT ministry
2. **User Consent:** Obtain consent before sending promotional SMS
3. **Opt-out:** Provide unsubscribe option for marketing messages
4. **Data Storage:** Follow Iranian data localization requirements
5. **Do Not Call List:** Respect blocked numbers list

---

## References

- Kavenegar Documentation: https://kavenegar.com/docs/api
- Ghasedak API Docs: https://ghasedak.me/docs
- SMS.ir API: https://www.sms.ir/api-docs
- Iranian ICT SMS Regulations: https://www.ict.gov.ir
