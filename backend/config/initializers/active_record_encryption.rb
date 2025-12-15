# Configure Active Record Encryption keys via ENV for all environments.
# This repo does not rely on encrypted credentials for these values.

Rails.application.config.active_record.encryption.primary_key =
  ENV.fetch('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY', ENV.fetch('active_record_encryption.primary_key', nil))

Rails.application.config.active_record.encryption.deterministic_key =
  ENV.fetch('ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY', ENV.fetch('active_record_encryption.deterministic_key', nil))

Rails.application.config.active_record.encryption.key_derivation_salt =
  ENV.fetch('ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT', ENV.fetch('active_record_encryption.key_derivation_salt', nil))
