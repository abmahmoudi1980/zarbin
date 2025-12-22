# Custom RSpec matcher to check if a hash has all specified keys
RSpec::Matchers.define :have_keys do |*expected_keys|
  match do |actual|
    return false unless actual.respond_to?(:keys)
    expected_keys.all? { |key| actual.key?(key) || actual.key?(key.to_sym) }
  end

  failure_message do |actual|
    missing = expected_keys.reject { |key| actual.key?(key) || actual.key?(key.to_sym) }
    "expected #{actual.inspect} to have keys #{expected_keys.inspect}, but missing: #{missing.inspect}"
  end

  failure_message_when_negated do |actual|
    "expected #{actual.inspect} not to have keys #{expected_keys.inspect}"
  end
end
