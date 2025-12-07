# Deployment Checklist - Zarbin MVP Foundation

**Version**: 1.0.0  
**Date**: December 2025  
**Feature**: 001-mvp-foundation

This checklist ensures all critical components are ready for production deployment.

---

## Pre-Deployment Verification

### Backend (Rails API)

- [x] **Database Setup**
  - [x] All migrations run successfully
  - [x] Database encryption configured for User.mobile_number
  - [x] Seed data created (7 categories)
  - [ ] Database backups configured
  - [ ] Connection pooling optimized for production

- [x] **Authentication & Security**
  - [x] JWT secret key configured (not default)
  - [x] Account lockout (5 attempts, 15 min) tested
  - [x] Token expiry (7 days) verified
  - [x] Password hashing (bcrypt) enabled
  - [x] Active Record Encryption enabled
  - [x] Rate limiting (100 req/min) active
  - [ ] HTTPS/TLS 1.3 enforced
  - [ ] CORS origins whitelisted

- [x] **Background Jobs**
  - [x] Solid Queue configured
  - [x] Market rates job (every 5 minutes during market hours)
  - [ ] Job monitoring/alerting configured
  - [ ] Dead job queue handling

- [x] **API Endpoints**
  - [x] All endpoints return proper status codes
  - [x] Error responses are consistent
  - [x] Input validation on all inputs
  - [x] XSS protection (sanitization) enabled
  - [ ] API versioning strategy documented
  - [ ] Rate limiting tested under load

- [ ] **Performance**
  - [x] Market rates endpoint < 3 seconds
  - [x] Dashboard endpoint < 2 seconds
  - [ ] Database indexes on frequently queried columns
  - [ ] Solid Cache configured and working
  - [ ] N+1 query issues resolved

- [ ] **Logging & Monitoring**
  - [x] Authentication events logged
  - [x] Transaction operations logged
  - [x] Error tracking configured
  - [ ] Log rotation configured
  - [ ] Performance monitoring (APM) enabled
  - [ ] Alert thresholds configured

- [ ] **Testing**
  - [x] All RSpec tests passing
  - [ ] 80%+ code coverage achieved
  - [x] Security tests passed
  - [x] Performance benchmarks met
  - [ ] Load testing completed

### Frontend (Flutter Mobile)

- [x] **Build Configuration**
  - [x] Release build tested on Android
  - [ ] Release build tested on iOS
  - [ ] App signing configured
  - [ ] Version number set correctly
  - [ ] Build number incremented

- [x] **API Integration**
  - [x] Production API URL configured
  - [x] Token refresh logic working
  - [x] Error handling for all API calls
  - [x] Offline mode gracefully handled
  - [ ] Timeout values appropriate

- [x] **Localization**
  - [x] Persian fonts loaded
  - [x] RTL layout working
  - [x] Jalali calendar integrated
  - [x] Persian numerals displayed
  - [ ] All strings externalized

- [x] **User Experience**
  - [x] Error dialogs user-friendly
  - [x] Offline indicators visible
  - [x] Loading states on all screens
  - [x] Form validation comprehensive
  - [ ] Accessibility features enabled

- [ ] **Performance**
  - [ ] App launch < 3 seconds
  - [ ] Dashboard load < 2 seconds
  - [ ] Smooth scrolling (60 FPS)
  - [ ] Memory usage optimized
  - [ ] Battery usage acceptable

- [ ] **Security**
  - [x] JWT tokens stored securely (flutter_secure_storage)
  - [ ] No sensitive data in logs
  - [ ] ProGuard/R8 enabled (Android)
  - [ ] Bitcode enabled (iOS)
  - [ ] SSL pinning configured

- [ ] **Testing**
  - [x] Widget tests passing
  - [ ] Integration tests passing
  - [ ] 80%+ code coverage achieved
  - [ ] Manual testing on multiple devices
  - [ ] Beta testing feedback incorporated

### External Services

- [x] **SMS OTP (Kavenegar)**
  - [x] API credentials configured
  - [x] OTP sending working
  - [x] OTP verification working
  - [ ] Rate limits understood
  - [ ] Billing/credits monitored
  - [ ] Fallback plan if service down

- [x] **Market Data (TGJU)**
  - [x] API integration working
  - [x] Fallback to cached rates on failure
  - [x] Rate update frequency correct (5 min)
  - [ ] API rate limits understood
  - [ ] Alternative data source identified

### Infrastructure

- [ ] **Server/Hosting**
  - [ ] Production server provisioned
  - [ ] Kamal deployment configured
  - [ ] HTTPS certificate installed (Let's Encrypt)
  - [ ] Firewall rules configured
  - [ ] DDoS protection enabled
  - [ ] CDN configured (if needed)

- [ ] **Database**
  - [ ] PostgreSQL 15+ running
  - [ ] Automated backups configured (daily)
  - [ ] Backup restoration tested
  - [ ] Connection limits appropriate
  - [ ] Monitoring configured

- [ ] **Domain & DNS**
  - [ ] Domain registered
  - [ ] DNS records configured
  - [ ] SSL certificate matches domain
  - [ ] API subdomain (api.zarbin.ir) configured

### CI/CD Pipeline

- [ ] **Automation**
  - [ ] GitHub Actions workflow configured
  - [ ] Automated tests on push/PR
  - [ ] Automated deployment to staging
  - [ ] Manual approval for production
  - [ ] Rollback procedure documented

### Documentation

- [x] **Technical Documentation**
  - [x] API contracts documented (OpenAPI)
  - [x] Data model documented
  - [x] Architecture decisions recorded
  - [ ] Deployment guide complete
  - [ ] Troubleshooting guide complete

- [ ] **User Documentation**
  - [ ] User guide/FAQ created
  - [ ] Privacy policy published
  - [ ] Terms of service published
  - [ ] Support contact information

### Compliance & Legal

- [ ] **Data Privacy**
  - [x] User data encrypted at rest
  - [ ] GDPR compliance reviewed (if applicable)
  - [ ] Data retention policy defined
  - [ ] Data deletion process implemented
  - [ ] Privacy policy covers all data usage

- [ ] **App Store Requirements**
  - [ ] Google Play Developer account
  - [ ] App description in Persian
  - [ ] Screenshots (5+) prepared
  - [ ] Privacy policy URL provided
  - [ ] App content rating obtained

---

## Deployment Steps

### 1. Pre-Deployment

1. [ ] Run full test suite: `./backend/run_tests.sh`
2. [ ] Run frontend tests: `cd frontend && flutter test`
3. [ ] Review all security settings
4. [ ] Backup current production database (if updating)
5. [ ] Notify users of planned maintenance window

### 2. Backend Deployment

1. [ ] Set environment variables on production server
2. [ ] Run database migrations: `rails db:migrate`
3. [ ] Deploy with Kamal: `kamal deploy`
4. [ ] Verify background jobs running: `rails solid_queue:status`
5. [ ] Test all API endpoints manually
6. [ ] Check logs for errors: `tail -f log/production.log`

### 3. Frontend Deployment

1. [ ] Update API base URL to production
2. [ ] Build release APK: `flutter build apk --release`
3. [ ] Test release build on physical device
4. [ ] Upload to Google Play Console (Internal Testing track)
5. [ ] Verify app works with production API
6. [ ] Promote to Production track when ready

### 4. Post-Deployment

1. [ ] Smoke test: Register → Login → Add Transaction → View Dashboard
2. [ ] Monitor error logs for 1 hour
3. [ ] Monitor server performance (CPU, memory, disk)
4. [ ] Verify background jobs running correctly
5. [ ] Test OTP sending with real phone number
6. [ ] Check market rates updating every 5 minutes

---

## Rollback Procedure

If critical issues are discovered after deployment:

1. [ ] Stop accepting new traffic (maintenance mode)
2. [ ] Revert to previous Kamal deployment: `kamal rollback`
3. [ ] Restore database backup if needed
4. [ ] Verify rollback successful
5. [ ] Communicate issue to users
6. [ ] Investigate root cause

---

## Success Criteria

Deployment is considered successful when:

- ✅ All user stories (US1-US5) working end-to-end
- ✅ No critical errors in logs after 1 hour
- ✅ Performance targets met (SC-002, SC-004)
- ✅ User registration and login working (SC-001)
- ✅ Background jobs running without errors
- ✅ App approved on Google Play (Internal Testing)

---

## Emergency Contacts

- **Backend Developer**: [TBD]
- **Frontend Developer**: [TBD]
- **DevOps**: [TBD]
- **SMS Provider (Kavenegar)**: support@kavenegar.com
- **Hosting Provider**: [TBD]

---

## Notes

- First deployment - expect issues
- Have rollback plan ready
- Monitor closely for first 24 hours
- Collect user feedback actively
- Schedule post-mortem meeting

**Last Updated**: December 2025
