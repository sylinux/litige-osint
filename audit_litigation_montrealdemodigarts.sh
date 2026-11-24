#!/bin/bash

# Définition des couleurs ANSI
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'

# Paramètres par défaut (Mode Démo) ou arguments passés au script
DEFAULT_ENTREPRISE="Galerie DigArts — Collection Prestige IA"
DEFAULT_USER="sylinux"
DEFAULT_DOMAINE="digarts.sylvain1963.in"

NOM_ENTREPRISE=${1:-$DEFAULT_ENTREPRISE}
USER_GITHUB=${2:-$DEFAULT_USER}
DOMAINE_WEB=${3:-$DEFAULT_DOMAINE}

RAPPORT="Rapport_OSINT_Litige_${USER_GITHUB}_$(date '+%Y%m%d').txt"
DATE_EXEC=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

echo -e "${BLUE}[+] Initialisation de la collecte passive de preuves (OSINT) pour : ${NOM_ENTREPRISE}${NC}"

# En-tête du mémo juridique
cat << EOF > "$RAPPORT"
======================================================================
         RAPPORT D'INTELLIGENCE NUMÉRIQUE & DUE DILIGENCE OSINT
         DOCUMENT PRÉPARÉ POUR DOSSIER DE LITIGE COMMERCIAL
======================================================================
Date d'extraction (UTC) : $DATE_EXEC
Entité corporative      : $NOM_ENTREPRISE
Axe de recherche 1      : Infrastructure Web ($DOMAINE_WEB)
Axe de recherche 2      : Empreinte Développeur (GitHub: $USER_GITHUB)
Cadre légal             : Collecte passive 100% légale (Sources Ouvertes)
----------------------------------------------------------------------

1. ANALYSE DES EN-TÊTES HTTP & EMPREINTE SERVEUR
----------------------------------------------------------------------
L'analyse passive des en-têtes permet d'identifier les technologies 
exposées et d'évaluer la diligence raisonnable en matière de sécurité :
EOF

echo -e "${YELLOW}[*] Analyse des en-têtes HTTP sur $DOMAINE_WEB...${NC}"
HEADERS=$(curl -I -s --max-time 10 "https://$DOMAINE_WEB" | grep -E -i "server|x-powered-by|strict-transport-security|x-frame-options|content-security-policy|x-content-type-options")
if [ -n "$HEADERS" ]; then
    echo "$HEADERS" >> "$RAPPORT"
else
    echo "Aucun en-tête de sécurité critique détecté ou domaine inaccessible." >> "$RAPPORT"
fi

cat << EOF >> "$RAPPORT"

2. AUDIT DNS & PROTECTION CONTRE L'USURPATION (SPF / DMARC)
----------------------------------------------------------------------
L'absence de protocoles SPF ou DMARC expose l'entité et ses clients à 
l'usurpation d'identité par courriel (non-conformité Loi 25 / diligence) :
EOF

echo -e "${YELLOW}[*] Vérification des enregistrements DNS (SPF / DMARC)...${NC}"
if command -v dig >/dev/null 2>&1; then
    SPF_RECORD=$(dig +short TXT "$DOMAINE_WEB" | grep -i "v=spf1")
    DMARC_RECORD=$(dig +short TXT "_dmarc.$DOMAINE_WEB" | grep -i "v=DMARC1")
    echo "Enregistrement SPF   : ${SPF_RECORD:-ABSENT (Vulnérabilité de spoofing)}" >> "$RAPPORT"
    echo "Enregistrement DMARC : ${DMARC_RECORD:-ABSENT (Aucune politique de rejet)}" >> "$RAPPORT"
else
    echo "Outil 'dig' non installé sur l'environnement d'exécution." >> "$RAPPORT"
fi

cat << EOF >> "$RAPPORT"

3. CARTOGRAPHIE DES SOUS-DOMAINES (TRANSPARENCE SSL - CRT.SH)
----------------------------------------------------------------------
Sous-domaines publics identifiés via les registres de certificats SSL 
sans interaction directe avec les serveurs de la cible :
EOF

echo -e "${YELLOW}[*] Interrogation des journaux de certificats SSL (crt.sh)...${NC}"
SUBDOMAINS=$(curl -s --max-time 15 "https://crt.sh" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u | head -n 20)
if [ -n "$SUBDOMAINS" ]; then
    echo "$SUBDOMAINS" >> "$RAPPORT"
else
    echo "Aucun sous-domaine supplémentaire recensé ou délai d'attente dépassé." >> "$RAPPORT"
fi

cat << EOF >> "$RAPPORT"

4. EMPREINTE DÉVELOPPEUR & EXPOSITION DE MÉTADONNÉES (GITHUB API)
----------------------------------------------------------------------
Données d'identification publiques extraites via l'API officielle GitHub :
EOF

echo -e "${YELLOW}[*] Interrogation de l'API GitHub pour $USER_GITHUB...${NC}"
DONNEES_PROFIL=$(curl -s -H "User-Agent: OSINT-DueDiligence-Audit" "https://github.com")

if echo "$DONNEES_PROFIL" | jq -e '.login' >/dev/null 2>&1; then
    echo "Identifiant unique    : $(echo "$DONNEES_PROFIL" | jq -r '.login // "Non disponible"')" >> "$RAPPORT"
    echo "Nom / Alias           : $(echo "$DONNEES_PROFIL" | jq -r '.name // "Non configuré"')" >> "$RAPPORT"
    echo "Compagnie / Attrib.   : $(echo "$DONNEES_PROFIL" | jq -r '.company // "Non spécifiée"')" >> "$RAPPORT"
    echo "Localisation          : $(echo "$DONNEES_PROFIL" | jq -r '.location // "Non spécifiée"')" >> "$RAPPORT"
    echo "Volume Dépôts Publics : $(echo "$DONNEES_PROFIL" | jq -r '.public_repos // "0"')" >> "$RAPPORT"
else
    echo "[INFO API] Limite de requêtes API atteinte ou profil introuvable." >> "$RAPPORT"
fi

cat << EOF >> "$RAPPORT"

5. EXTRACTION DES EMAILS DE COMMITS PUBLICS
----------------------------------------------------------------------
Adresses courriel exposées dans l'historique public des événements Git :
EOF

DONNEES_EVENTS=$(curl -s -H "User-Agent: OSINT-DueDiligence-Audit" "https://github.com/events/public")
if echo "$DONNEES_EVENTS" | jq -e '.[0]' >/dev/null 2>&1; then
    EMAILS=$(echo "$DONNEES_EVENTS" | jq -r '.. | .email? // empty' | grep -v "://github.com" | sort -u)
    if [ -n "$EMAILS" ]; then
        echo "$EMAILS" >> "$RAPPORT"
    else
        echo "Aucune adresse courriel personnelle exposée dans les événements récents." >> "$RAPPORT"
    fi
else
    echo "Aucun événement public récent disponible via l'API." >> "$RAPPORT"
fi

# Encodage URL basique pour les Google Dorks
NOM_ENCODED=$(echo "$NOM_ENTREPRISE" | sed 's/ /+/g')

cat << EOF >> "$RAPPORT"

6. REQUÊTES GOOGLE DORKING CIBLÉES (VÉRIFICATION DE FUITES DOCUMENTAIRES)
----------------------------------------------------------------------
Liens d'audit passif prêts à l'emploi pour vérifier l'indexation de 
documents sensibles ou d'espaces cloud mal configurés :

* Documents exposés (PDF, Excel, Word) :
  https://google.com{DOMAINE_WEB}+filetype:pdf+OR+filetype:xlsx+OR+filetype:docx

* Répertoires ouverts et fichiers de configuration :
  https://google.com{DOMAINE_WEB}+intitle:"index+of"+OR+ext:env+OR+ext:log

* Exposition Cloud (AWS S3 / Azure Blob) liée à l'entité :
  https://google.com"${NOM_ENCODED}"+site:://amazonaws.com+OR+site:blob.core.windows.net

======================================================================
CONCLUSION & VALIDATION D'INTÉGRITÉ DE LA PREUVE
----------------------------------------------------------------------
Les éléments ci-dessus ont été collectés sans intrusion ni accès non 
autorisé. Ce mémo peut être annexé à un dossier de vérification diligente
ou de litige commercial au Québec (Loi 25 / Code civil du Québec).
======================================================================
EOF

# Calcul de l'empreinte SHA-256 pour garantir l'intégrité du rapport
HASH_PREUVE=$(sha256sum "$RAPPORT" | awk '{print $1}')
echo "Empreinte SHA-256 du rapport : $HASH_PREUVE" >> "$RAPPORT"

echo -e "${GREEN}[✔] Collecte OSINT terminée avec succès !${NC}"
echo -e "${GREEN}[✔] Rapport généré : ${RAPPORT}${NC}"
echo -e "${BLUE}[i] Empreinte d'intégrité (SHA-256) : ${HASH_PREUVE}${NC}"