# Load the Rails application.
require_relative "application"

# Load environment variables from .env files
ENV_FILE = File.expand_path("../../.env", __dir__)
ENV_LOCAL_FILE = File.expand_path("../../.env.local", __dir__)
ENV_TEST_FILE = File.expand_path("../.env.test", __dir__)

if File.exist?(ENV_FILE)
  File.foreach(ENV_FILE) do |line|
    line.strip!
    next if line.empty? || line.start_with?("#")
    key, value = line.split("=", 2)
    next unless key && value
    ENV[key] ||= value.sub(/^["']|["']$/, '')
  end
end

if File.exist?(ENV_LOCAL_FILE)
  File.foreach(ENV_LOCAL_FILE) do |line|
    line.strip!
    next if line.empty? || line.start_with?("#")
    key, value = line.split("=", 2)
    next unless key && value
    ENV[key] = value.sub(/^["']|["']$/, '')
  end
end

if ENV['RAILS_ENV'] == 'test' && File.exist?(ENV_TEST_FILE)
  File.foreach(ENV_TEST_FILE) do |line|
    line.strip!
    next if line.empty? || line.start_with?("#")
    key, value = line.split("=", 2)
    next unless key && value
    ENV[key] ||= value.sub(/^["']|["']$/, '')
  end
end

if ENV['RAILS_ENV'] == 'test'
  ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'] ||= ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY']
  ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY'] ||= ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY']
  ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT'] ||= ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']

  ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'] ||= '0' * 64
  ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY'] ||= '1' * 64
  ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT'] ||= '2' * 64

  ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'] ||= ENV['active_record_encryption.primary_key']
  ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY'] ||= ENV['active_record_encryption.deterministic_key']
  ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT'] ||= ENV['active_record_encryption.key_derivation_salt']

  ENV['active_record_encryption.primary_key'] ||= ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY']
  ENV['active_record_encryption.deterministic_key'] ||= ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY']
  ENV['active_record_encryption.key_derivation_salt'] ||= ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']
end

# Initialize the Rails application.
Rails.application.initialize!
