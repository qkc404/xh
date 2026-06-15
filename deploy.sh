#!/bin/bash

BOLD='\033[1m'; RESET='\033[0m'
GREEN='\033[1;32m'; RED='\033[1;31m'; CYAN='\033[1;36m'
YELLOW='\033[1;33m'; BLUE='\033[1;34m'

loading() {
    local text="$1"
    local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    for ((i=0; i<10; i++)); do
        for ((j=0; j<${#spin}; j++)); do
            echo -ne "\r${CYAN}${spin:$j:1} ${text}...${RESET}"
            sleep 0.05
        done
    done
    echo -ne "\r${GREEN}DONE: ${text}${RESET}\n"
}

clear
echo -e "${BLUE}────────────────────────────────────────────────────${RESET}"
echo -e "${CYAN}     VLESS FAST DEPLOYER MADE BY SAEKA TOJIRP${RESET}"
echo -e "${CYAN}     (☞ ^o^) ☞ fb.com/saekacutiee | newbie${RESET}"
echo -e "${BLUE}────────────────────────────────────────────────────${RESET}"

PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')

read -r -p "$(echo -e "${CYAN}  NAME (*´ω｀*) [service name]: ${RESET}")" INPUT_NAME
SERVICE_NAME=${INPUT_NAME:-vless-proxy}

echo -e "\n${CYAN} SELECT PERFORMANCE (◠‿◕): ${RESET}"
echo -e "${YELLOW}  1) 1 vCPU / 2Gi RAM${RESET}"
echo -e "${YELLOW}  2) 2 vCPU / 4Gi RAM${RESET}"
echo -e "${YELLOW}  3) 4 vCPU / 8Gi RAM${RESET}"
read -r -p "$(echo -e "${CYAN}  CHOICE [2]: ${RESET}")" PAIR_CHOICE

case "$PAIR_CHOICE" in
    1) CPU="1"; RAM="2Gi" ;;
    3) CPU="4"; RAM="8Gi" ;;
    *) CPU="2"; RAM="4Gi" ;;
esac

echo -e "\n${CYAN} PROCESSING ( ꈍᴗꈍ)... ${RESET}"

loading "BUILDING IMAGE ( ╹▽╹ ) "
# CRITICAL FIX: Force Cloud Build to use Dockerfile
gcloud builds submit --tag "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" . --quiet
if [ $? -ne 0 ]; then
    echo -e "${RED}BUILD FAILED!${RESET}"
    exit 1
fi

loading "CONFIGURING CLOUD RUN ADJUSTMENTS ( ꈍᴗꈍ) "
gcloud run deploy "$SERVICE_NAME" \
  --image "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" \
  --platform managed \
  --region us-central1 \
  --cpu "$CPU" \
  --memory "$RAM" \
  --port 8080 \
  --concurrency 1000 \
  --cpu-boost \
  --no-cpu-throttling \
  --timeout 3600 \
  --min-instances 1 \
  --max-instances 4 \
  --allow-unauthenticated \
  --quiet > deploy.log 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}DEPLOYMENT FAILED (╥﹏╥)!${RESET}"
    tail -n 10 deploy.log
    exit 1
fi

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region us-central1 --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

echo -e "\n${BLUE}────────────────────────────────────────────────────${RESET}"
echo -e "${CYAN} DEPLOYED SUCCESSFULLY (◠‿・)—☆ ${RESET}"
echo -e "${CYAN} FULL URL (｡•̀ᴗ-)  ${GREEN}${SERVICE_URL}${RESET}"
echo -e "${BLUE}────────────────────────────────────────────────────${RESET}"

rm -f build.log deploy.log
