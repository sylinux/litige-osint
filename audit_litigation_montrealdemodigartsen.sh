#!/bin/bash

# ANSI Color Definitions
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'

# Default Parameters (Demo Mode) or CLI Arguments
DEFAULT_COMPANY="DigArts Gallery — AI Prestige Collection"
DEFAULT_USER="sylinux"
DEFAULT_DOMAIN="digarts.sylvain1963.in"

TARGET_COMPANY=${1:-$DEFAULT_COMPANY}
GITHUB_USER=${2:-$DEFAULT_USER}
WEB_DOMAIN=${3:-$DEFAULT_DOMAIN}

REPORT="Report_OSINT_Litigation_${GITHUB_USER}_$(date '+%Y%m%d').txt"
EXEC_DATE=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

echo -e "${BLUE}[+] Initializing passive OSINT evidence collection for: ${TARGET_COMPANY}${NC}"

# Legal Memo Header
cat << EOF > "$REPORT"
======================================================================
         DIGITAL INTELLIGENCE & OSINT DUE DILIGENCE REPORT
         DOCUMENT PREPARED FOR COMMERCIAL LITIGATION DISCOVERY
======================================================================
Extraction Date (UTC) : $EXEC_DATE
Corporate Entity      : $TARGET_COMPANY
Research Vector 1     : Web Infrastructure ($WEB_DOMAIN)
Research Vector 2     : Developer Footprint (GitHub: $GITHUB_USER)
Legal Framework       : 100% Passive Open-Source Collection (Non-Intrusive)
----------------------------------------------------------------------

1. HTTP SECURITY HEADERS & SERVER FINGERPRINTING
----------------------------------------------------------------------
Passive header analysis identifies exposed technologies and evaluates 
reasonable due diligence regarding information security standards:
EOF

echo -e "${YELLOW}[*] Analyzing HTTP headers on $WEB_DOMAIN...${NC}"
HEADERS=$(curl -I -s --max-time 10 "https://$WEB_DOMAIN" | grep -E -i "server|x-powered-by|strict-transport-security|x-frame-options|content-security-policy|x-content-type-options")
if [ -n "$HEADERS" ]; then
    echo "$HEADERS" >> "$REPORT"
else
    echo "No critical security headers detected or domain unreachable." >> "$REPORT"
fi

cat << EOF >> "$REPORT"

2. DNS AUDIT & ANTI-SPOOFING COMPLIANCE (SPF / DMARC)
----------------------------------------------------------------------
The absence of SPF or DMARC protocols exposes the entity and its clients 
to email spoofing and identity impersonation risks:
EOF

echo -e "${YELLOW}[*] Checking DNS records via DoH (SPF / DMARC)...${NC}"
SPF_RECORD=$(curl -s "https://dns.google{WEB_DOMAIN}&type=TXT" | jq -r '.Answer[]?.data // empty' | grep -i "v=spf1" | tr -d '"')
DMARC_RECORD=$(curl -s "https://dns.google{WEB_DOMAIN}&type=TXT" | jq -r '.Answer[]?.data // empty' | grep -i "v=DMARC1" | tr -d '"')
echo "SPF Record   : ${SPF_RECORD:-MISSING (Spoofing vulnerability)}" >> "$REPORT"
echo "DMARC Record : ${DMARC_RECORD:-MISSING (No reject/quarantine policy)}" >> "$REPORT"

cat << EOF >> "$REPORT"

3. SUBDOMAIN DISCOVERY (SSL CERTIFICATE TRANSPARENCY - CRT.SH)
----------------------------------------------------------------------
Public subdomains identified via SSL certificate transparency logs 
without direct active scanning of target servers:
EOF

echo -e "${YELLOW}[*] Querying SSL Certificate Transparency logs (crt.sh)...${NC}"
SUBDOMAINS=$(curl -s --max-time 15 "https://crt.sh" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u | head -n 20)
if [ -n "$SUBDOMAINS" ]; then
    echo "$SUBDOMAINS" >> "$REPORT"
else
    echo "No additional subdomains recorded or query timed out." >> "$REPORT"
fi

cat << EOF >> "$REPORT"

4. DEVELOPER FOOTPRINT & PUBLIC METADATA (GITHUB API)
----------------------------------------------------------------------
Public corporate and technical attribution data extracted via GitHub API:
EOF

echo -e "${YELLOW}[*] Querying GitHub API for $GITHUB_USER...${NC}"
PROFILE_DATA=$(curl -s -H "User-Agent: OSINT-DueDiligence-Audit" "https://github.com")

if echo "$PROFILE_DATA" | jq -e '.login' >/dev/null 2>&1; then
    echo "Unique Handle        : $(echo "$PROFILE_DATA" | jq -r '.login // "N/A"')" >> "$REPORT"
    echo "Name / Alias         : $(echo "$PROFILE_DATA" | jq -r '.name // "Not configured"')" >> "$REPORT"
    echo "Company / Attribution: $(echo "$PROFILE_DATA" | jq -r '.company // "Not specified"')" >> "$REPORT"
    echo "Location             : $(echo "$PROFILE_DATA" | jq -r '.location // "Not specified"')" >> "$REPORT"
    echo "Public Repositories  : $(echo "$PROFILE_DATA" | jq -r '.public_repos // "0"')" >> "$REPORT"
else
    echo "[API INFO] API rate limit reached or profile not found." >> "$REPORT"
fi

cat << EOF >> "$REPORT"

5. PUBLIC COMMIT METADATA GOVERNANCE AUDIT
----------------------------------------------------------------------
Public email addresses exposed in Git event logs (for privacy governance 
and data leak remediation assessment):
EOF

EVENTS_DATA=$(curl -s -H "User-Agent: OSINT-DueDiligence-Audit" "https://github.com/events/public")
if echo "$EVENTS_DATA" | jq -e '.' >/dev/null 2>&1; then
    EMAILS=$(echo "$EVENTS_DATA" | jq -r '.. | .email? // empty' | grep -v "://github.com" | sort -u)
    if [ -n "$EMAILS" ]; then
        echo "$EMAILS" >> "$REPORT"
    else
        echo "No personal email addresses exposed in recent public events." >> "$REPORT"
    fi
else
    echo "No recent public events available via API." >> "$REPORT"
fi

# Basic URL encoding for Google Dorks
COMPANY_ENCODED=$(echo "$TARGET_COMPANY" | sed 's/ /+/g')

cat << EOF >> "$REPORT"

6. TARGETED GOOGLE DORKING QUERIES (DOCUMENT EXPOSURE AUDIT)
----------------------------------------------------------------------
Ready-to-use passive search links to verify public indexing of sensitive 
documents or misconfigured cloud storage buckets:

* Exposed Documents (PDF, Excel, Word):
  https://google.com{WEB_DOMAIN}+filetype:pdf+OR+filetype:xlsx+OR+filetype:docx

* Open Directories & Configuration Files:
  https://google.com{WEB_DOMAIN}+intitle:"index+of"+OR+ext:env+OR+ext:log

* Cloud Storage Exposure (AWS S3 / Azure Blob) linked to entity:
  https://google.com"${COMPANY_ENCODED}"+site:://amazonaws.com+OR+site:blob.core.windows.net

======================================================================
CONCLUSION & EVIDENTIARY INTEGRITY VALIDATION
----------------------------------------------------------------------
The findings above were collected passively without unauthorized access. 
This memo may be annexed to a digital due diligence file or commercial 
litigation discovery record.
======================================================================
EOF

# Compute SHA-256 hash to guarantee report integrity
EVIDENCE_HASH=$(sha256sum "$REPORT" | awk '{print $1}')
echo "Report SHA-256 Checksum: $EVIDENCE_HASH" >> "$REPORT"

echo -e "${GREEN}[✔] OSINT collection completed successfully!${NC}"
echo -e "${GREEN}[✔] Report generated: ${REPORT}${NC}"
echo -e "${BLUE}[i] Integrity Checksum (SHA-256): ${EVIDENCE_HASH}${NC}"