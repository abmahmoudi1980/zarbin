# Load the Rails application.
require_relative "application"

# Load environment variables from .env files
ENV_FILE = File.expand_path("../../.env", __dir__)
ENV_LOCAL_FILE = File.expand_path("../../.env.local", __dir__)

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

# Initialize the Rails application.
Rails.application.initialize!
