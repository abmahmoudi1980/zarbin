#!/bin/bash
# Backend Test Runner
# Executes RSpec test suite and generates coverage report

set -e

echo "========================================"
echo "Running Zarbin Backend Test Suite"
echo "========================================"
echo ""

cd "$(dirname "$0")"

# Check if bundle is available
if ! command -v bundle &> /dev/null; then
    echo "Error: bundler not installed"
    exit 1
fi

# Install dependencies if needed
echo "📦 Checking dependencies..."
bundle check || bundle install

# Run RSpec with coverage
echo ""
echo "🧪 Running RSpec tests with coverage..."
bundle exec rspec --format documentation --color

# Check coverage
echo ""
echo "📊 Test Coverage Report:"
if [ -f coverage/.last_run.json ]; then
    echo "Coverage report generated in coverage/"
    echo "Open coverage/index.html in a browser to view detailed report"
fi

# Run RuboCop linting
echo ""
echo "🔍 Running RuboCop linting..."
bundle exec rubocop || echo "⚠️  RuboCop found issues (see above)"

echo ""
echo "========================================"
echo "✅ Test suite completed"
echo "========================================"
