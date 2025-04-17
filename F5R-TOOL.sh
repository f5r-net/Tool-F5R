#!/data/data/com.termux/files/usr/bin/bash

# File: F5R-TOOL.sh
# Ultimate APK Management Suite with Multi-Language Support
# Version: 25.0 Pro Max+
# Updated: 2024-06-26

# ──────────────────── Global Settings ────────────────────
RED='\033[1;31m'       GREEN='\033[1;32m'
YELLOW='\033[1;33m'    CYAN='\033[1;36m'
BLUE='\033[1;34m'      PURPLE='\033[1;35m'
WHITE='\033[1;37m'     NC='\033[0m'

APKTOOL_VERSION="2.9.3"
APKTOOL_REPO="https://github.com/iBotPeaches/Apktool"
VIRUSTOTAL_API=""
TELEGRAM_BOT=""
TELEGRAM_CHAT=""

BASE_DIR="$HOME/storage/shared/F5R_APK_Suite"
DIR_STRUCTURE=(
    "$BASE_DIR/APKs" "$BASE_DIR/Decompiled_Projects"
    "$BASE_DIR/Rebuilt_APKs" "$BASE_DIR/Analysis_Reports"
    "$BASE_DIR/Logs" "$BASE_DIR/Certificates"
    "$BASE_DIR/temp_processing" "$BASE_DIR/plugins"
)

# ──────────────────── Language System ────────────────────
load_language() {
    lang=$(getprop persist.sys.locale | cut -d- -f1)
    [ "$lang" = "ar" ] && lang="ar" || lang="en"
    source <(
        [ "$lang" = "ar" ] && cat <<'AR'
msg_decompile="تفكيك APK"
msg_recompile="تجميع APK"
msg_analysis="تحليل متقدم"
msg_report="تقرير HTML"
msg_exit="خروج"
AR
        [ "$lang" = "en" ] && cat <<'EN'
msg_decompile="Decompile APK"
msg_recompile="Recompile APK"
msg_analysis="Advanced Analysis"
msg_report="Generate Report"
msg_exit="Exit"
EN
    )
}

# ──────────────────── Environment Setup ────────────────────
initialize() {
    termux-setup-storage
    for dir in "${DIR_STRUCTURE[@]}"; do
        [ ! -d "$dir" ] && mkdir -p "$dir"
    done

    if [ ! -f "$BASE_DIR/Certificates/debug.keystore" ]; then
        keytool -genkeypair -v -keystore "$BASE_DIR/Certificates/debug.keystore" \
        -alias android -keyalg RSA -keysize 4096 -validity 10000 \
        -storepass android -keypass android \
        -dname "CN=Android,O=Android,C=US"
    fi

    [ ! -f "config.cfg" ] && {
        echo -e "${CYAN}[*] First-time setup:"
        read -p "Virustotal API Key: " VIRUSTOTAL_API
        read -p "Telegram Bot Token: " TELEGRAM_BOT
        read -p "Telegram Chat ID: " TELEGRAM_CHAT
        echo "VIRUSTOTAL_API='$VIRUSTOTAL_API'" > config.cfg
        echo "TELEGRAM_BOT='$TELEGRAM_BOT'" >> config.cfg
        echo "TELEGRAM_CHAT='$TELEGRAM_CHAT'" >> config.cfg
    }
    source config.cfg
}

# ──────────────────── Core Operations ────────────────────
decompile_apk() {
    apk_list=($(find "$BASE_DIR/APKs" -type f -name "*.apk"))
    [ ${#apk_list[@]} -eq 0 ] && {
        echo -e "${RED}[!] No APKs found${NC}"
        return
    }

    PS3="$(echo -e ${WHITE}Select APK: ${NC})"
    select apk in "${apk_list[@]}" "Cancel"; do
        [ "$apk" = "Cancel" ] && return
        output_dir="$BASE_DIR/Decompiled_Projects/$(basename "$apk" .apk)"
        apktool d -f "$apk" -o "$output_dir" && {
            echo -e "${GREEN}[✓] Decompiled: $output_dir${NC}"
            CURRENT_PROJECT="$output_dir"
        } || echo -e "${RED}[✗] Decompilation failed${NC}"
        break
    done
}

recompile_apk() {
    [ -z "$CURRENT_PROJECT" ] && {
        echo -e "${RED}[!] No project selected${NC}"
        return
    }

    output_apk="$BASE_DIR/Rebuilt_APKs/$(basename "$CURRENT_PROJECT")_rebuilt.apk"
    apktool b "$CURRENT_PROJECT" -o "$output_apk" && {
        jarsigner -verbose -keystore "$BASE_DIR/Certificates/debug.keystore" \
        -storepass android "$output_apk" android
        echo -e "${GREEN}[✓] APK signed: $output_apk${NC}"
    } || echo -e "${RED}[✗] Rebuild failed${NC}"
}

# ──────────────────── Advanced Features ────────────────────
network_analysis() {
    timeout 30 tcpdump -i any -s 0 -w "$BASE_DIR/temp_processing/network.pcap" &>/dev/null &
    adb install -r "$output_apk"
    adb shell am start -n "$(grep 'package' "$CURRENT_PROJECT/AndroidManifest.xml" | cut -d\" -f2)/.MainActivity"
    sleep 30
    echo -e "${CYAN}[*] PCAP saved: $BASE_DIR/temp_processing/network.pcap${NC}"
}

generate_report() {
    report_file="$BASE_DIR/Analysis_Reports/$(basename "$CURRENT_PROJECT").html"
    cat <<HTML > "$report_file"
<html><body>
<h1>APK Forensic Report</h1>
<h2>Permissions</h2>
<pre>$(grep 'uses-permission' "$CURRENT_PROJECT/AndroidManifest.xml")</pre>
<h2>Network Endpoints</h2>
<pre>$(grep -Ero 'https?://[^"'\''<> ]+' "$CURRENT_PROJECT/smali")</pre>
</body></html>
HTML
    echo -e "${GREEN}[✓] Report generated: $report_file${NC}"
}

# ──────────────────── UI System ────────────────────
show_menu() {
    clear
    echo -e "${CYAN}"
    [ "$lang" = "ar" ] && cat <<'AR'
┌─────────────────────────────┐
│      أداة F5R المتكاملة    │
├─────────────────────────────┤
│ 1) تفكيك APK               │
│ 2) تجميع APK               │
│ 3) تحليل الشبكة            │
│ 4) إنشاء تقرير             │
│ 5) إرسال إشعار             │
│ 6) خروج                     │\n│ 7) دمج تطبيقين APK         │\n│ 8) دمج إعدادات Firebase     │
│ 9) دمج GitHub وسجل الأخطاء │

│ 10) فحص MobSF               │
│ 11) تحليل ديناميكي         │
│ 12) تجاوز SSL Pinning      │
│ 13) فحص QARK                │
│ 14) واجهة TUI محسّنة        │
│ 15) إعداد CI/CD             │
│ 16) تحديث الأداة أوتوماتيكي  │
│ 17) ملخص تنفيذي OpenAI      │
│ 18) تقييم الخطر             │
│ 19) إشعارات متقدمة          │

└─────────────────────────────┘
AR
    [ "$lang" = "en" ] && cat <<'EN'
┌─────────────────────────────┐
│      F5R Ultimate Suite     │
├─────────────────────────────┤
│ 1) Decompile APK            │
│ 2) Recompile APK            │
│ 3) Network Analysis         │
│ 4) Generate Report          │
│ 5) Send Notification        │
│ 6) Exit                     │
└─────────────────────────────┘
EN
    echo -n -e "${WHITE}[?] ${NC}"
}

# ──────────────────── Main Execution ────────────────────
load_language
initialize
check_dependencies() {
    required=("apktool" "jarsigner" "adb" "tcpdump")
    for cmd in "${required[@]}"; do
        ! command -v "$cmd" && {
            echo -e "${RED}[✗] Missing: $cmd${NC}"
            exit 1
        }
    done
}
check_dependencies

while true; do
    show_menu
    read choice
    case $choice in
        1) decompile_apk ;;
        2) recompile_apk ;;
        3) network_analysis ;;
        4) generate_report ;;
        5) curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT}/sendMessage" -d "chat_id=${TELEGRAM_CHAT}&text=APK+Processing+Complete" ;;
        6) exit 0 ;;
        7) merge_apks ;;
        8) inject_firebase ;;
        9) inject_github ;; 
        10) mobsf_scan ;;
        11) dynamic_analysis ;;
        12) bypass_ssl ;;
        13) qark_scan ;;
        14) enhanced_tui ;;
        15) setup_ci_cd ;;
        16) auto_update ;;
        17) openai_summary ;;
        18) risk_scoring ;;
        19) advanced_notify ;;

        *) echo -e "${RED}[!] Invalid option${NC}" ;;
    esac
    echo -e "\n${WHITE}Press Enter...${NC}"
    read
done

# ──────────────────── Merge Feature ────────────────────

merge_apks() {
    apk_list=($(find "$BASE_DIR/APKs" -type f -name "*.apk"))
    [ ${#apk_list[@]} -lt 2 ] && {
        echo -e "${RED}[!] يجب أن يكون هناك على الأقل تطبيقين${NC}"
        return
    }

    echo -e "${WHITE}[1] اختر التطبيق الأساسي:${NC}"
    select apk_main in "${apk_list[@]}"; do
        [ -n "$apk_main" ] && break
    done

    echo -e "${WHITE}[2] اختر التطبيق الذي سيتم دمجه مع الأساسي:${NC}"
    select apk_merge in "${apk_list[@]}"; do
        [ -n "$apk_merge" ] && break
    done

    main_dir="$BASE_DIR/Decompiled_Projects/$(basename "$apk_main" .apk)_main"
    merge_dir="$BASE_DIR/Decompiled_Projects/$(basename "$apk_merge" .apk)_merge"

    apktool d -f "$apk_main" -o "$main_dir" >/dev/null
    apktool d -f "$apk_merge" -o "$merge_dir" >/dev/null

    cp -rn "$merge_dir/smali/"* "$main_dir/smali/" 2>/dev/null
    cp -rn "$merge_dir/res/"* "$main_dir/res/" 2>/dev/null

    echo -e "\n<!-- Manifest from merged APK: $(basename "$apk_merge") -->\n$(cat "$merge_dir/AndroidManifest.xml")" >> "$main_dir/AndroidManifest.xml"

    output_apk="$BASE_DIR/Rebuilt_APKs/merged_$(basename "$apk_main" .apk)_$(basename "$apk_merge" .apk).apk"
    apktool b "$main_dir" -o "$output_apk"

    jarsigner -verbose -keystore "$BASE_DIR/Certificates/debug.keystore" \
        -storepass android "$output_apk" android

    echo -e "${GREEN}[✓] تم دمج التطبيقين في: $output_apk${NC}"
}

# ──────────────────── دمج Firebase تلقائيًا ────────────────────
inject_firebase() {
    apk_list=($(find "$BASE_DIR/APKs" -type f -name "*.apk"))
    [ ${#apk_list[@]} -eq 0 ] && {
        echo -e "${RED}[!] لا توجد ملفات APK في المجلد.${NC}"
        return
    }

    echo -e "${WHITE}اختر التطبيق الذي تريد دمج Firebase معه:${NC}"
    select apk in "${apk_list[@]}" "Cancel"; do
        [ "$apk" = "Cancel" ] && return
        break
    done

    project_name=$(basename "$apk" .apk)
    output_dir="$BASE_DIR/Decompiled_Projects/${project_name}_firebase"
    apktool d -f "$apk" -o "$output_dir"

    firebase_json_path="$BASE_DIR/firebase/google-services.json"
    if [ ! -f "$firebase_json_path" ]; then
        echo -e "${RED}[!] ملف google-services.json غير موجود في المسار: $firebase_json_path${NC}"
        echo -e "${YELLOW}[?] الرجاء وضعه في: $BASE_DIR/firebase${NC}"
        return
    fi

    mkdir -p "$output_dir/assets"
    cp "$firebase_json_path" "$output_dir/assets/google-services.json"
    echo -e "${GREEN}[✓] تم نسخ إعدادات Firebase إلى مجلد assets${NC}"

    # إضافة خدمة Firebase إلى AndroidManifest.xml إن لم تكن موجودة
    if ! grep -q "com.google.firebase" "$output_dir/AndroidManifest.xml"; then
        sed -i '/<application/a\        <meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@mipmap/ic_launcher"/>' "$output_dir/AndroidManifest.xml"
        sed -i '/<application/a\        <service android:name="com.google.firebase.messaging.FirebaseMessagingService" android:exported="true"/>' "$output_dir/AndroidManifest.xml"
        echo -e "${CYAN}[+] تم تعديل AndroidManifest.xml لإضافة Firebase Services${NC}"
    fi

    # إعادة بناء التطبيق
    output_apk="$BASE_DIR/Rebuilt_APKs/${project_name}_with_firebase.apk"
    apktool b "$output_dir" -o "$output_apk"

    jarsigner -verbose -keystore "$BASE_DIR/Certificates/debug.keystore" \
        -storepass android "$output_apk" android

    echo -e "${GREEN}[✓] تم دمج Firebase وإنشاء التطبيق الجديد: $output_apk${NC}"
}


# ──────────────────── دمج GitHub وسجل الأخطاء تلقائيًا ────────────────────
inject_github() {
    apk_list=($(find "$BASE_DIR/APKs" -type f -name "*.apk"))
    [ ${#apk_list[@]} -eq 0 ] && { echo -e "${RED}[!] لا توجد ملفات APK.${NC}"; return; }

    echo -e "${WHITE}اختر التطبيق لإضافة GitHub logging وسجل الأخطاء:${NC}"
    select apk in "${apk_list[@]}" "Cancel"; do
        [ "$apk" = "Cancel" ] && return
        [ -n "$apk" ] && break
    done

    project_name=$(basename "$apk" .apk)
    project_dir="$BASE_DIR/Decompiled_Projects/${project_name}_github"
    apktool d -f "$apk" -o "$project_dir"

    # Sentry DSN
    if ! grep -q "SENTRY_DSN" config.cfg; then
        read -p "أدخل Sentry DSN: " SENTRY_DSN
        echo "SENTRY_DSN='$SENTRY_DSN'" >> config.cfg
    else
        SENTRY_DSN=$(grep -oP "(?<=SENTRY_DSN=')[^']+" config.cfg)
    fi

    # Insert Sentry init in MainActivity smali
    main_smali=$(grep -rl "onCreate" "$project_dir/smali" | head -1)
    sed -i "/invoke-super/a \
    const-string v0, \"$SENTRY_DSN\"\
    invoke-static {v0}, Lio/sentry/Sentry;->init(Ljava/lang/String;)V" "$main_smali"
    echo -e "${GREEN}[+] تم إضافة Sentry init في: $main_smali${NC}"

    # GitHub repo URL
    if ! grep -q "GITHUB_REPO" config.cfg; then
        read -p "أدخل GitHub repo URL (HTTPS): " GITHUB_REPO
        echo "GITHUB_REPO='$GITHUB_REPO'" >> config.cfg
    else
        GITHUB_REPO=$(grep -oP "(?<=GITHUB_REPO=')[^']+" config.cfg)
    fi

    # Initialize Git, commit, and push
    cd "$project_dir"
    git init
    git remote add origin "$GITHUB_REPO"
    git add .
    git commit -m "Add Sentry error logging integration"
    git push -u origin master
    cd -

    # Rebuild and sign APK
    output_apk="$BASE_DIR/Rebuilt_APKs/${project_name}_with_github.apk"
    apktool b "$project_dir" -o "$output_apk"
    jarsigner -verbose -keystore "$BASE_DIR/Certificates/debug.keystore" \
        -storepass android "$output_apk" android

    echo -e "${GREEN}[✓] تم إنشاء APK مع سجل الأخطاء وGitHub: $output_apk${NC}"
}



# ──────────────────── MobSF Integration ────────────────────
mobsf_scan() {
    echo -e "${CYAN}[+] Starting MobSF scan...${NC}"
    apk=$(find "$BASE_DIR/APKs" -type f -name "*.apk" | fzf)
    [ -z "$apk" ] && return
    # Assuming MobSF API is running locally on port 8000
    api_key=$(grep -oP "(?<=MOBSF_API_KEY=')[^']+" config.cfg)
    response=$(curl -s -H "Authorization: $api_key" -F "file=@$apk" http://127.0.0.1:8000/api/v1/upload)
    scan_url=$(echo "$response" | jq -r '.json.scan_url')
    analysis=$(curl -s -H "Authorization: $api_key" -F "scan_url=$scan_url" http://127.0.0.1:8000/api/v1/scan)
    echo "$analysis" > "$BASE_DIR/Analysis_Reports/$(basename "$apk").mobsf.json"
    echo -e "${GREEN}[✓] MobSF report saved.${NC}"
}

# ──────────────────── Dynamic Frida Analysis ────────────────────
dynamic_analysis() {
    echo -e "${CYAN}[+] Starting dynamic analysis with Frida...${NC}"
    apk=$(find "$BASE_DIR/APKs" -type f -name "*.apk" | fzf)
    [ -z "$apk" ] && return
    adb install -r "$apk"
    frida -U -f $(aapt dump badging "$apk" | grep package:\ name | cut -d"'" -f2) -l ./scripts/frida_dynamic.js --no-pause
}

# ──────────────────── SSL Pinning Bypass ────────────────────
bypass_ssl() {
    echo -e "${CYAN}[+] Bypassing SSL Pinning...${NC}"
    apk=$(find "$BASE_DIR/APKs" -type f -name "*.apk" | fzf)
    [ -z "$apk" ] && return
    # Placeholder for SSL bypass implementation
    echo -e "${YELLOW}[!] SSL pinning bypass script not implemented.${NC}"
}

# ──────────────────── QARK Analysis ────────────────────
qark_scan() {
    echo -e "${CYAN}[+] Running QARK...${NC}"
    apk=$(find "$BASE_DIR/APKs" -type f -name "*.apk" | fzf)
    [ -z "$apk" ] && return
    qark --source "$apk" --report-dir "$BASE_DIR/Analysis_Reports/$(basename "$apk" .apk)_qark"
    echo -e "${GREEN}[✓] QARK report generated.${NC}"
}

# ──────────────────── Enhanced TUI ────────────────────
enhanced_tui() {
    echo -e "${CYAN}[+] Enhanced TUI with fzf and gum${NC}"
    # Example: list APKs with fzf
    apk=$(find "$BASE_DIR/APKs" -type f -name "*.apk" | fzf --preview="aapt dump badging {}")
    echo -e "${GREEN}[✓] Selected: $apk${NC}"
}

# ──────────────────── CI/CD Workflow ────────────────────
setup_ci_cd() {
    echo -e "${CYAN}[+] Generating GitHub Actions workflow...${NC}"
    mkdir -p .github/workflows
    cat <<EOF > .github/workflows/android-analysis.yml
name: Android APK Analysis

on:
  push:
    paths:
      - 'APKs/**'

jobs:
  analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run APK Tool
        run: bash tool.sh
      - name: Upload Reports
        uses: actions/upload-artifact@v2
        with:
          name: analysis-reports
          path: Analysis_Reports/
EOF
    echo -e "${GREEN}[✓] CI/CD workflow created.${NC}"
}

# ──────────────────── Auto-Update Tool ────────────────────
auto_update() {
    echo -e "${CYAN}[+] Checking for script updates...${NC}"
    latest=$(curl -s https://api.github.com/repos/YourRepo/F5R-Tool/releases/latest | jq -r '.tag_name')
    if [ "\$latest" != "\$VERSION" ]; then
        echo -e "${YELLOW}[!] Update available: \$latest. Updating...${NC}"
        wget https://raw.githubusercontent.com/YourRepo/F5R-Tool/\$latest/tool.sh -O tool.sh
        echo -e "${GREEN}[✓] Updated to \$latest. Please restart the tool.${NC}"
        exit 0
    else
        echo -e "${GREEN}[✓] You have the latest version.\${NC}"
    fi
}

# ──────────────────── ChatGPT Executive Summary ────────────────────
openai_summary() {
    echo -e "${CYAN}[+] Generating executive summary via OpenAI...${NC}"
    report=$(cat "$BASE_DIR/Analysis_Reports/$(basename "$apk").html")
    summary=$(curl -s https://api.openai.com/v1/completions       -H "Content-Type: application/json"       -H "Authorization: Bearer \$OPENAI_API_KEY"       -d "{
        "model": "gpt-4o-mini",
        "prompt": "Please summarize the following APK analysis report in Arabic: \$report",
        "max_tokens": 300
      }")
    echo "$summary" > "$BASE_DIR/Analysis_Reports/$(basename "$apk")_summary.txt"
    echo -e "${GREEN}[✓] Summary generated.${NC}"
}

# ──────────────────── Risk Scoring ────────────────────
risk_scoring() {
    echo -e "${CYAN}[+] Calculating risk score...${NC}"
    # Simple example: count permissions and MobSF issues
    apk=$(find "$BASE_DIR/APKs" -type f -name "*.apk" | fzf)
    perm_count=$(grep -c 'uses-permission' "$BASE_DIR/Decompiled_Projects/$(basename "$apk" .apk)/AndroidManifest.xml")
    mob_issues=$(jq '.results | length' "$BASE_DIR/Analysis_Reports/$(basename "$apk").mobsf.json")
    score=$((perm_count + mob_issues))
    echo -e "${GREEN}[✓] Risk Score: \$score${NC}"
}

# ──────────────────── Advanced Notifications ────────────────────
advanced_notify() {
    echo -e "${CYAN}[+] Sending advanced notifications...${NC}"
    # Slack webhook
    if [ ! -z "$SLACK_WEBHOOK" ]; then
        curl -s -X POST -H 'Content-type: application/json'           --data "{"text":"APK Analysis Completed: $(basename "$apk")"}" \$SLACK_WEBHOOK
    fi
    # Email via sendmail
    echo "APK Analysis for $(basename "$apk") completed." | sendmail -v user@example.com
    echo -e "${GREEN}[✓] Notifications sent.${NC}"
}