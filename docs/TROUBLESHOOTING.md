# Troubleshooting Guide - Zarbin MVP Foundation

**Version**: 1.0.0  
**Last Updated**: December 2025

This guide helps diagnose and resolve common issues in the Zarbin application.

---

## Table of Contents

1. [Backend Issues](#backend-issues)
2. [Frontend Issues](#frontend-issues)
3. [Authentication Problems](#authentication-problems)
4. [API Integration Issues](#api-integration-issues)
5. [Background Jobs](#background-jobs)
6. [Performance Issues](#performance-issues)
7. [Database Problems](#database-problems)

---

## Backend Issues

### Rails Server Won't Start

**Symptoms**: `rails server` fails or exits immediately

**Possible Causes**:
- Port 3000 already in use
- Missing environment variables
- Database connection failure
- Missing dependencies

**Solutions**:
```bash
# Check if port is in use
lsof -i :3000

# Kill process using port 3000
kill -9 <PID>

# Check database connection
rails db:migrate:status

# Install missing gems
bundle install

# Check environment variables
rails credentials:show
```

### Database Migration Errors

**Symptoms**: `rails db:migrate` fails

**Common Errors**:

#### "PG::ConnectionBad"
```bash
# Check PostgreSQL is running
sudo service postgresql status

# Check database.yml configuration
cat config/database.yml

# Test connection manually
psql -U zarbin_user -d zarbin_development
```

#### "ActiveRecord::PendingMigrationError"
```bash
# Run pending migrations
rails db:migrate

# Check migration status
rails db:migrate:status
```

### API Returns 500 Errors

**Symptoms**: API endpoints returning Internal Server Error

**Debug Steps**:
1. Check Rails logs:
   ```bash
   tail -f log/development.log
   ```

2. Look for stack traces in logs

3. Common causes:
   - Missing database records
   - Nil object errors
   - Validation failures

4. Test in Rails console:
   ```ruby
   rails console
   # Reproduce the failing operation
   ```

---

## Frontend Issues

### Flutter Build Fails

**Symptoms**: `flutter build` or `flutter run` fails

**Common Solutions**:
```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade

# Check Flutter doctor
flutter doctor -v
```

### App Crashes on Startup

**Symptoms**: App opens then immediately closes

**Debug Steps**:
1. Check logs:
   ```bash
   flutter logs
   ```

2. Run in debug mode:
   ```bash
   flutter run --debug
   ```

3. Common causes:
   - Missing API configuration
   - Invalid secure storage
   - Unhandled exceptions in main.dart

4. Clear app data (Android):
   ```bash
   adb shell pm clear com.example.zarbin
   ```

### API Requests Failing

**Symptoms**: Network errors, timeouts, or 404s

**Check**:
1. API base URL in `lib/config/api_config.dart`
2. Backend server is running
3. Network connectivity
4. CORS configuration

**Debug**:
```dart
// Enable verbose logging in api_client.dart
LogInterceptor(
  requestBody: true,
  responseBody: true,
  requestHeader: true,
  responseHeader: true,
  logPrint: print,
)
```

---

## Authentication Problems

### "Invalid Credentials" on Login

**Symptoms**: User cannot log in with correct password

**Checks**:
1. Account status in database:
   ```ruby
   rails console
   user = User.find_by(mobile_number: '09123456789')
   user.account_status
   user.failed_login_attempts
   user.locked_until
   ```

2. Password hash exists:
   ```ruby
   user.password_digest.present?
   ```

3. Account not locked:
   ```ruby
   user.account_locked?
   # If locked, reset:
   user.update(failed_login_attempts: 0, locked_until: nil, account_status: :active)
   ```

### Account Locked

**Symptoms**: "Account is locked until HH:MM" message

**Resolution**:
1. Wait 15 minutes for automatic unlock
2. Or manually reset in console:
   ```ruby
   user = User.find_by(mobile_number: '09123456789')
   user.reset_failed_attempts
   ```

### JWT Token Expired

**Symptoms**: 401 Unauthorized after 7 days

**Expected Behavior**: Token should auto-refresh

**If Not Working**:
1. Check token refresh implementation in `api_client.dart`
2. Verify `/api/v1/auth/refresh` endpoint works
3. Clear secure storage and re-login:
   ```dart
   await SecureStorage().clearAll();
   ```

### OTP Not Received

**Symptoms**: User doesn't receive SMS with OTP code

**Checks**:
1. Kavenegar API credentials:
   ```bash
   rails credentials:show
   ```

2. Test OTP service manually:
   ```ruby
   rails console
   OtpService.new.send_otp('09123456789')
   ```

3. Check Kavenegar dashboard for:
   - Account balance
   - Message status
   - API errors

4. Check Rails logs for SMS errors:
   ```bash
   grep "OTP" log/development.log
   ```

---

## API Integration Issues

### Market Rates Not Updating

**Symptoms**: Rates older than 5 minutes, stale indicator showing

**Checks**:
1. Background job running:
   ```ruby
   rails console
   FetchMarketRatesJob.perform_now
   ```

2. TGJU API accessible:
   ```bash
   curl https://api.tgju.org/v2/live/usd
   ```

3. Check market hours (rates don't update outside Tehran Stock Exchange hours)

4. View job status:
   ```ruby
   SolidQueue::Job.last(10)
   ```

5. Check cached rates:
   ```ruby
   Rails.cache.read('market_rates:latest')
   ```

### Market Rates Return Empty

**Symptoms**: GET `/api/v1/rates` returns empty array

**Solution**:
```ruby
rails console
# Manually trigger rate fetch
MarketDataService.fetch_and_store_rates

# Verify rates exist
MarketRate.all
```

---

## Background Jobs

### Solid Queue Jobs Not Running

**Symptoms**: Market rates not updating, jobs stuck

**Debug Steps**:
1. Check Solid Queue status:
   ```bash
   rails solid_queue:status
   ```

2. Check database for failed jobs:
   ```ruby
   SolidQueue::Job.where(status: 'failed')
   ```

3. Restart Solid Queue:
   ```bash
   rails solid_queue:stop
   rails solid_queue:start
   ```

4. Check logs:
   ```bash
   tail -f log/solid_queue.log
   ```

### Job Failures

**Symptoms**: Jobs show as failed in database

**Resolution**:
```ruby
rails console
# View failed job details
job = SolidQueue::Job.where(status: 'failed').last
job.error_message
job.backtrace

# Retry failed job
job.retry!
```

---

## Performance Issues

### Slow API Response Times

**Symptoms**: Requests take >3 seconds

**Debug**:
1. Check database query performance:
   ```ruby
   # In rails console with query logging enabled
   ActiveRecord::Base.logger = Logger.new(STDOUT)
   ```

2. Look for N+1 queries
3. Check Solid Cache hit rate:
   ```ruby
   Rails.cache.stats
   ```

4. Profile slow endpoints:
   ```ruby
   # Add to controller action
   Benchmark.measure do
     # code to benchmark
   end
   ```

### High Memory Usage

**Symptoms**: Server using excessive RAM

**Checks**:
1. Check running processes:
   ```bash
   ps aux | grep rails
   ```

2. Monitor memory:
   ```bash
   free -h
   top
   ```

3. Check for memory leaks in background jobs

4. Restart Rails server

---

## Database Problems

### Connection Pool Exhausted

**Symptoms**: "could not obtain a connection from the pool"

**Solutions**:
```yaml
# In config/database.yml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 10 } %>
```

Restart server after changes.

### Database Locked

**Symptoms**: "database is locked" errors (SQLite only)

**Note**: PostgreSQL is recommended for production. If using SQLite:
```bash
# Check for long-running transactions
rails dbconsole
.timeout 5000
```

### Missing Indexes

**Symptoms**: Slow queries

**Solution**:
```ruby
# In rails console
# Check for missing indexes
ActiveRecord::Base.connection.tables.each do |table|
  puts "Table: #{table}"
  puts ActiveRecord::Base.connection.indexes(table)
end

# Add indexes via migration
rails generate migration AddIndexToTransactionsUserId
```

---

## Common Error Messages

### "Errno::ECONNREFUSED: Connection refused"

**Cause**: Backend server not running

**Solution**:
```bash
rails server
```

### "DioError [DioErrorType.connectTimeout]"

**Cause**: Backend server slow or unreachable

**Solution**:
1. Check backend is running
2. Verify API URL in `api_config.dart`
3. Increase timeout if needed

### "NoMethodError: undefined method for nil:NilClass"

**Cause**: Missing database record or uninitialized variable

**Solution**:
1. Check database for expected records
2. Add nil checks in code
3. Review controller logic

### "ActiveRecord::RecordNotFound"

**Cause**: Trying to access non-existent record

**Solution**:
1. Use `find_by` instead of `find`
2. Add error handling
3. Verify ID parameter is correct

---

## Getting Help

### Logs to Check

1. **Rails Logs**: `log/development.log` or `log/production.log`
2. **Flutter Logs**: `flutter logs`
3. **System Logs**: `/var/log/syslog`
4. **PostgreSQL Logs**: `/var/log/postgresql/`

### Debugging Tools

1. **Rails Console**: `rails console`
2. **Database Console**: `rails dbconsole`
3. **Flutter DevTools**: `flutter pub global run devtools`
4. **Network Inspector**: Charles Proxy or Wireshark

### Useful Commands

```bash
# Check Rails environment
rails about

# Check routes
rails routes

# Run specific test
rspec spec/path/to/test_spec.rb

# Check Flutter connectivity
flutter doctor

# Clear all caches
rails cache:clear
flutter clean
```

---

## Reporting Issues

When reporting a bug, include:

1. **Environment**: Development, Staging, or Production
2. **Error Message**: Complete stack trace
3. **Steps to Reproduce**: Exact steps that trigger the issue
4. **Expected vs Actual**: What should happen vs what happens
5. **Logs**: Relevant excerpts from logs
6. **Screenshots**: If UI-related

---

**Need More Help?**

Contact: [Your support channel]

**Last Updated**: December 2025
