<!--
================================================================================
SYNC IMPACT REPORT
================================================================================
Version Change: 1.0.1 → 1.0.2
Bump Rationale: PATCH - Define localization requirements

Modified Principles:
  - III. Local-First Architecture → III. Responsive & Resilient UX
    (Removed offline-mandatory requirements; focus on UX responsiveness)
  - V. Simplicity & YAGNI rationale updated

Modified Sections:
  - Technology Stack: Added Localization (v1.0) subsection
    (Persian default, English secondary, Jalali-only dates)

Added Sections:
  - Core Principles (5 principles)
  - Technology Stack
  - Development Workflow
  - Governance

Removed Sections: None (first version)

Templates Requiring Updates:
  ✅ plan-template.md - Constitution Check section compatible
  ✅ spec-template.md - Requirements/success criteria align with principles
  ✅ tasks-template.md - Task organization compatible with TDD principle
  ✅ checklist-template.md - Generic format, no updates needed
  ✅ agent-file-template.md - Generic format, no updates needed

Follow-up TODOs: None
================================================================================
-->

# Zarbin Constitution

**AI-Powered Personal Financial Advisor for High-Inflation Economies**

## Core Principles

### I. Inflation-Centric Design (NON-NEGOTIABLE)

All features MUST prioritize **purchasing power preservation** over nominal value tracking.

- Every monetary display MUST show dual representation: nominal IRR and real value (USD/Gold equivalent)
- Budget calculations MUST use inflation-adjusted purchasing power, not static Rial amounts
- Investment recommendations MUST factor in projected inflation rates
- Historical data visualizations MUST normalize values to current purchasing power
- The "Save-to-Asset" engine MUST treat idle cash as depreciating inventory

**Rationale**: This is Zarbin's core differentiator. Standard budgeting apps assume stable currency; Zarbin exists because the Rial does not behave that way. Every feature decision flows from this principle.

### II. Privacy-First Data Handling (NON-NEGOTIABLE)

User financial data is sacred; security MUST be embedded at every layer.

- All sensitive data MUST use Rails Active Record Encryption at rest
- SMS parsing MUST occur on-device; raw SMS content MUST NOT transmit to backend
- API communications MUST use TLS 1.3 minimum
- User credentials MUST NOT be stored; use token-based authentication only
- Logs MUST NOT contain PII (account numbers, balances, transaction details)
- Third-party integrations (exchanges, market APIs) MUST use read-only access patterns

**Rationale**: Financial data in the Iranian context carries elevated risk. Users must trust that Zarbin protects their information from both external threats and internal misuse.

### III. Responsive & Resilient UX

The app MUST provide a fast, uninterrupted user experience.

- Manual transaction entry MUST remain responsive during API calls
- Historical data and charts SHOULD cache locally to reduce latency
- Sync operations MUST be idempotent and conflict-resilient
- Market rate data MUST refresh in real-time with clear loading indicators
- Flutter app SHOULD cache recent data locally using SQLite/Hive for instant loads
- Background sync MUST NOT block user interactions

**Rationale**: Users expect instant feedback in financial apps. Caching and optimistic UI updates provide a premium feel and reduce perceived latency.

### IV. Test-Driven Development

Financial calculations MUST be verified through comprehensive automated testing.

- All monetary calculations MUST have unit tests covering edge cases (rounding, overflow, zero values)
- Exchange rate conversions MUST have contract tests validating API response parsing
- SMS parsing regexes MUST have integration tests with real bank SMS samples
- The TDD cycle applies: Write failing test → Implement → Refactor
- Minimum 80% code coverage for `models/` and `services/` directories
- CI pipeline MUST block merges on test failures

**Rationale**: A bug in financial calculations directly harms users. "My budget said I had money but I didn't" destroys trust instantly.

### V. Simplicity & YAGNI

Start minimal; complexity MUST be justified and documented.

- Phase 1 (MVP) features MUST ship before any Phase 2 features begin
- New dependencies MUST justify their inclusion (no "just in case" libraries)
- Rails 8 Solid Queue/Cache MUST be used before considering Redis
- Database schemas MUST start normalized; denormalize only with benchmarks proving need
- UI screens MUST have ≤ 3 primary actions visible at once
- Over-engineering violations MUST be logged in Complexity Tracking tables

**Rationale**: A lean team building for a niche market cannot afford feature bloat. Rails 8's "no-Redis" philosophy reduces operational complexity.

## Technology Stack

The following stack is mandated for all Zarbin development:

| Layer | Technology | Version | Justification |
|-------|------------|---------|---------------|
| Backend Framework | Ruby on Rails | 8.x | Solid Queue/Cache, Kamal deployment, Active Record Encryption |
| Backend Language | Ruby | 3.4+ | YJIT performance for low-latency API responses |
| Mobile Framework | Flutter | Latest stable | Single codebase for Android/iOS, native RTL/Persian as default language |
| Mobile Storage | Hive or SQLite | Latest | Local caching for responsive UX and instant loads |
| Background Jobs | Solid Queue | Rails 8 built-in | No Redis dependency, simpler infrastructure |
| Caching | Solid Cache | Rails 8 built-in | Database-backed, simpler deployment |
| Deployment | Kamal | Latest | Containerized deployment to any VPS |
| Database | PostgreSQL | 15+ | Robust, encrypted storage for financial data |

**Constraints**:
- MUST NOT introduce Redis unless Solid Queue/Cache benchmarks prove inadequate
- MUST NOT use third-party authentication services (implement in-house for data sovereignty)

**Localization (v1.0)**:
- Persian (Farsi) is the DEFAULT language; all UI text, labels, and messages MUST be in Persian first
- English is the SECONDARY language; translations provided but not the default experience
- Jalali (Shamsi) calendar is the ONLY date system in v1; Gregorian support deferred to future versions
- All date inputs, displays, and pickers MUST use Jalali format (e.g., ۱۴۰۴/۰۹/۱۶)

## Development Workflow

### Code Review Requirements

- All PRs MUST pass Constitution Check before merge approval
- Financial calculation changes MUST have two reviewers
- SMS parser regex changes MUST include test cases from real bank SMS samples
- Security-sensitive changes MUST be flagged with `[SECURITY]` prefix in PR title

### Quality Gates

1. **Pre-Commit**: Linting (RuboCop for Rails, flutter analyze for mobile)
2. **CI Pipeline**: Full test suite, security scanning, coverage threshold check
3. **Pre-Merge**: Constitution compliance verification, reviewer approval
4. **Post-Deploy**: Smoke tests on staging, market data API connectivity check

### Branching Strategy

- `main`: Production-ready, protected
- `develop`: Integration branch for features
- `feature/###-name`: Individual feature branches
- `hotfix/###-name`: Production emergency fixes

## Governance

This Constitution supersedes all other development practices and guidelines.

**Amendment Process**:
1. Propose amendment with rationale in a dedicated PR
2. Impact assessment on existing code and templates required
3. Approval from project lead required
4. Version increment follows semantic versioning:
   - MAJOR: Principle removal or fundamental redefinition
   - MINOR: New principle or significant expansion
   - PATCH: Clarifications, wording improvements
5. Update all dependent templates and documentation

**Compliance Review**:
- All PRs MUST include Constitution Check section
- Violations MUST be documented with justification in Complexity Tracking
- Quarterly review of constitution relevance and principle effectiveness

**Guidance Files**:
- Use `.specify/templates/agent-file-template.md` for runtime development guidance generation
- Plans MUST reference this constitution in their Constitution Check section

**Version**: 1.0.2 | **Ratified**: 2025-12-06 | **Last Amended**: 2025-12-06
