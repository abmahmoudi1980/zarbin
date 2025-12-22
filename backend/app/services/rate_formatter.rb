# frozen_string_literal: true

class RateFormatterService
  # Format a rate with Jalali date and Persian numerals
  # Used to prepare rate data for display on frontend
  
  class << self
    def format_rate(market_rate)
      {
        rate_type: market_rate.rate_type,
        value_in_toman: market_rate.value_in_toman,
        value_in_toman_persian: convert_to_persian_numerals(market_rate.value_in_toman),
        label: market_rate.rate_label,
        label_persian: rate_label_persian(market_rate.rate_type),
        timestamp: market_rate.timestamp.iso8601,
        timestamp_jalali: format_jalali_date(market_rate.timestamp),
        timestamp_jalali_time: format_jalali_datetime(market_rate.timestamp),
        stale: market_rate.stale?,
        stale_minutes: calculate_stale_minutes(market_rate.timestamp)
      }
    end

    def format_rates(market_rates)
      market_rates.map { |rate| format_rate(rate) }
    end

    # Convert Gregorian date to Jalali (Shamsi) format
    # Returns string like "۱۴۰۴/۰۹/۱۶"
    def format_jalali_date(datetime)
      jdate = to_jalali_date(datetime)
      "#{jdate[:year]}/#{jdate[:month].to_s.rjust(2, '0')}/#{jdate[:day].to_s.rjust(2, '0')}"
    end

    # Convert Gregorian datetime to Jalali format with time
    # Returns string like "۱۴۰۴/۰۹/۱۶ ۱۴:۳۰"
    def format_jalali_datetime(datetime)
      jdate = to_jalali_date(datetime)
      time_str = datetime.strftime("%H:%M")
      "#{jdate[:year]}/#{jdate[:month].to_s.rjust(2, '0')}/#{jdate[:day].to_s.rjust(2, '0')} #{time_str}"
    end

    # Convert Persian/Farsi numerals to English
    # "۱۲۳۴۵" -> "12345"
    def persian_to_english_numerals(text)
      persian_digits = %w(۰ ۱ ۲ ۳ ۴ ۵ ۶ ۷ ۸ ۹)
      english_digits = %w(0 1 2 3 4 5 6 7 8 9)
      
      result = text.to_s
      persian_digits.each_with_index do |persian, index|
        result = result.gsub(persian, english_digits[index])
      end
      result
    end

    # Convert English numerals to Persian/Farsi
    # "12345" -> "۱۲۳۴۵"
    def convert_to_persian_numerals(number)
      persian_digits = %w(۰ ۱ ۲ ۳ ۴ ۵ ۶ ۷ ۸ ۹)
      number.to_s.each_char.map { |digit| persian_digits[digit.to_i] || digit }.join
    end

    # Format number with Persian numerals and thousand separators
    # 1234567 -> "۱٬۲۳۴٬۵۶۷"
    def format_number_persian(number)
      # First, add thousand separators
      formatted = number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      # Then convert to Persian numerals
      convert_to_persian_numerals(formatted)
    end

    # Get Persian label for rate type
    def rate_label_persian(rate_type)
      case rate_type
      when 'usd'
        'دلار آمریکا'
      when 'gold_gram'
        'طلا (گرم)'
      when 'bahar_coin'
        'سکه بهار آزادی'
      else
        rate_type
      end
    end

    # Get English label for rate type
    def rate_label_english(rate_type)
      case rate_type
      when 'usd'
        'USD'
      when 'gold_gram'
        'Gold (gram)'
      when 'bahar_coin'
        'Bahar Azadi Coin'
      else
        rate_type
      end
    end

    private

    # Convert Gregorian date to Jalali date
    # Returns hash with :year, :month, :day
    def to_jalali_date(datetime)
      g_y = datetime.year
      g_m = datetime.month
      g_d = datetime.day

      # Calculate Jalali date
      if g_m > 2
        jy = g_y + 1600
      else
        jy = g_y + 1599
      end

      if g_m > 2
        gm = g_m - 3
      else
        gm = g_m + 9
      end

      a = ((14 - gm) / 12).to_i
      y = g_y + 4800 - a
      m = gm + (12 * a) - 2

      jd = (g_d + (((153 * m) + 2) / 5).to_i + (365 * y).to_i + (y / 4).to_i -
            (y / 100).to_i + (y / 400).to_i - 32045) -
           ((1948440 + (365 * jy).to_i + ((jy / 33).to_i * 8) + (((jy % 33) + 3) / 4).to_i - 38840 - 1).to_i)

      jy = jy - ((jd + 1) / 365.2422).to_i if jd > 365

      if jd <= 0
        jy -= 1
        jd += 365 + (is_leap_jalali(jy) ? 1 : 0)
      end

      jp = 0
      loop do
        jp += 1
        break if jd <= (is_leap_jalali(jy) && jp == 12 ? 30 : (jp % 7 == 0 ? 31 : 30))
        jd -= (is_leap_jalali(jy) && jp == 12 ? 30 : (jp % 7 == 0 ? 31 : 30))
      end

      { year: jy + 979, month: jp, day: jd }
    end

    # Check if a Jalali year is a leap year
    def is_leap_jalali(jy)
      (((((jy + 1309) * 682) - 110) % 2816) < 682)
    end

    def calculate_stale_minutes(timestamp)
      ((Time.current - timestamp) / 60).ceil
    end
  end
end
