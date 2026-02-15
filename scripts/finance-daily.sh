#!/bin/bash
# Daily Finance Tracking Script
# Script Name: finance-daily.sh
# Purpose: Automate daily financial tracking and reporting
# Frequency: Run daily at 23:00 UTC via cron
# Author: Rem
# Version: 1.0.0
# Created: 2026-02-15
# Last Modified: 2026-02-15

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPANY_DIR="/root/company-structure"
FINANCE_DIR="$COMPANY_DIR/finance"
LOG_FILE="$FINANCE_DIR/finance-daily-$(date '+%Y-%m-%d').md"
BACKUP_COUNT=7  # Number of daily logs to keep

# Ensure finance directory exists
mkdir -p "$FINANCE_DIR"

# Initialize log file
{
    echo "# Daily Finance Log - $(date '+%Y-%m-%d %H:%M:%S UTC')"
    echo ""
    echo "## Executive Summary"
    echo ""
    echo "### Daily Overview"
    echo "- **Date**: $(date '+%Y-%m-%d')"
    echo "- **Tracking Period**: 24 hours"
    echo "- **Automation Status**: Initial implementation"
    echo "- **Data Sources**: Manual entry pending automated API integration"
    echo ""
    echo "## Expenditure Tracking"
    echo ""
    echo "### Infrastructure Costs"
    echo ""
    echo "*No automated tracking yet - manual entry required*"
    echo ""
    echo "### Development Tools"
    echo ""
    echo "*No automated tracking yet - manual entry required*"
    echo ""
    echo "### Security Infrastructure"
    echo ""
    echo "*No automated tracking yet - manual entry required*"
    echo ""
    echo "### Team Operations"
    echo ""
    echo "*No automated tracking yet - manual entry required*"
    echo ""
    echo "## Revenue Tracking"
    echo ""
    echo "*No automated tracking yet - manual entry required*"
    echo ""
    echo "## Manual Entry Template"
    echo ""
    echo "### For manual expense/revenue entries:"
    echo '```markdown'
    echo "## [YYYY-MM-DD] - [Transaction Reference]"
    echo ""
    echo "### [Category: Infrastructure/Development/Security/Team/Revenue]"
    echo ""
    echo "**Service/Item**: [Service Name/Item Description]"
    echo "**Amount**: $[Amount]"
    echo "**Payment Method**: [Credit Card/Wire Transfer/Crypto/PayPal]"
    echo "**Invoice Reference**: [Invoice Number if applicable]"
    echo "**Recurring**: [Yes/No] - [Monthly/Quarterly/Annual]"
    echo "**Approved By**: [Veld/Gerard/Yukine/Rem]"
    echo "**Notes**: [Purpose/Justification/Special circumstances]"
    echo '```'
    echo ""
    echo "## System Information"
    echo ""
    echo "**Script Execution Time**: $(date '+%Y-%m-%d %H:%M:%S UTC')"
    echo "**Script Version**: 1.0.0"
    echo "**Automation Level**: Basic - Manual entry required"
    echo "**Next Improvement**: API integration for automated tracking"
    echo ""
    echo "## Notes & Anomalies"
    echo ""
    echo "- Initial finance tracking system implementation"
    echo "- Manual entry required until API integrations complete"
    echo "- Daily logs will be automatically committed to Git"
    echo "- Review and update this template as system evolves"
    echo ""
    echo "---"
    echo "*Automated by finance-daily.sh v1.0.0*"
} > "$LOG_FILE"

# Clean up old logs (keep only last $BACKUP_COUNT days)
cd "$FINANCE_DIR" && ls -t finance-daily-*.md | tail -n +$((BACKUP_COUNT+1)) | xargs rm -f 2>/dev/null

# Git operations
cd "$COMPANY_DIR" || exit 1

# Check if git is available
if command -v git >/dev/null 2>&1; then
    # Add and commit the log file
    git add "finance/finance-daily-$(date '+%Y-%m-%d').md"
    git commit -m "Daily finance log: $(date '+%Y-%m-%d')" >/dev/null 2>&1
    
    # Push to remote if configured
    if git remote -v | grep -q "origin"; then
        git push origin main >/dev/null 2>&1
        echo "Log committed and pushed to repository"
    else
        echo "Log committed locally (no remote configured)"
    fi
else
    echo "Git not available - log saved to $LOG_FILE"
fi

echo "Daily finance log created: $LOG_FILE"
echo "Next step: Implement API integrations for automated expense tracking"