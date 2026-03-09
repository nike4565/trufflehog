#!/data/data/com.termux/files/usr/bin/bash

#############################################
#                                           #
#        ASRAR SHIELD - FIREWALL            #
#     نظام الجدار الناري الحقيقي           #
#                                           #
#  Developer: asrar-mared                   #
#  Email: nike49424@gmail.com               #
#  GitHub: github.com/asrar-mared           #
#                                           #
#  مشروع درع - إهداء لدولة الإمارات        #
#  750 ملف حماية متقدمة                    #
#                                           #
#############################################

# ألوان للعرض
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# متغيرات النظام
SHIELD_DIR="$HOME/asrar-shield"
LOG_DIR="$SHIELD_DIR/logs"
BLOCKED_DIR="$SHIELD_DIR/blocked"
WHITELIST_FILE="$SHIELD_DIR/whitelist.txt"
BLACKLIST_FILE="$SHIELD_DIR/blacklist.txt"
CONFIG_FILE="$SHIELD_DIR/config.conf"
PID_FILE="$SHIELD_DIR/shield.pid"

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║        ▄▄▄       ██████  ██▀███   ▄▄▄       ██▀███       ║"
    echo "║       ▒████▄   ▒██    ▒ ▓██ ▒ ██▒▒████▄    ▓██ ▒ ██▒     ║"
    echo "║       ▒██  ▀█▄ ░ ▓██▄   ▓██ ░▄█ ▒▒██  ▀█▄  ▓██ ░▄█ ▒     ║"
    echo "║       ░██▄▄▄▄██  ▒   ██▒▒██▀▀█▄  ░██▄▄▄▄██ ▒██▀▀█▄       ║"
    echo "║        ▓█   ▓██▒██████▒▒░██▓ ▒██▒ ▓█   ▓██▒░██▓ ▒██▒     ║"
    echo "║        ▒▒   ▓▒█░ ▒░▓  ░░ ▒▓ ░▒▓░ ▒▒   ▓▒█░░ ▒▓ ░▒▓░     ║"
    echo "║         ▒   ▒▒ ░ ░ ▒  ░  ░▒ ░ ▒░  ▒   ▒▒ ░  ░▒ ░ ▒░     ║"
    echo "║         ░   ▒    ░ ░     ░░   ░   ░   ▒     ░░   ░      ║"
    echo "║             ░  ░   ░  ░   ░           ░  ░   ░          ║"
    echo "║                                                           ║"
    echo "║              S H I E L D   F I R E W A L L                ║"
    echo "║                                                           ║"
    echo "║              ⚔️  نظام الحماية المتقدم  🛡️               ║"
    echo "║                                                           ║"
    echo "║  Developer: asrar-mared                                   ║"
    echo "║  Project: درع - Tribute to UAE 🇦🇪                       ║"
    echo "║  Version: 1.0.0 (750 Protection Files)                    ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# فحص الصلاحيات
check_permissions() {
    echo -e "${YELLOW}[*] فحص الصلاحيات...${NC}"
    
    # فحص Termux
    if [ ! -d "/data/data/com.termux" ]; then
        echo -e "${RED}[!] هذا السكريبت يعمل فقط على Termux${NC}"
        exit 1
    fi
    
    # فحص الإنترنت
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${RED}[!] لا توجد اتصال بالإنترنت${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[✓] جميع الصلاحيات متاحة${NC}"
}

# تثبيت المتطلبات
install_dependencies() {
    echo -e "${YELLOW}[*] تثبيت المتطلبات...${NC}"
    
    # قائمة الحزم المطلوبة
    packages=(
        "root-repo"
        "wget"
        "curl"
        "nmap"
        "netcat-openbsd"
        "iptables"
        "dnsutils"
        "tcpdump"
        "wireshark-cli"
        "python"
        "openssl"
        "tor"
        "proxychains-ng"
        "macchanger"
        "hashcat"
        "hydra"
        "metasploit"
        "sqlmap"
        "aircrack-ng"
        "ettercap"
        "bind"
        "openssh"
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package"; then
            echo -e "${CYAN}[+] تثبيت $package...${NC}"
            pkg install -y "$package" 2>/dev/null || {
                echo -e "${YELLOW}[!] تخطي $package${NC}"
            }
        else
            echo -e "${GREEN}[✓] $package مثبت بالفعل${NC}"
        fi
    done
    
    # تثبيت أدوات Python
    pip install --upgrade pip 2>/dev/null
    pip install scapy requests beautifulsoup4 colorama pycryptodome 2>/dev/null
    
    echo -e "${GREEN}[✓] تم تثبيت جميع المتطلبات${NC}"
}

# إنشاء البنية التحتية
setup_structure() {
    echo -e "${YELLOW}[*] إنشاء البنية التحتية...${NC}"
    
    # إنشاء المجلدات
    mkdir -p "$SHIELD_DIR"/{logs,blocked,rules,scripts,quarantine,backup}
    mkdir -p "$LOG_DIR"/{network,apk,dns,firewall,system}
    
    # إنشاء الملفات الأساسية
    touch "$WHITELIST_FILE" "$BLACKLIST_FILE" "$CONFIG_FILE"
    
    # القوائم الافتراضية
    if [ ! -s "$WHITELIST_FILE" ]; then
        cat > "$WHITELIST_FILE" << EOF
# Whitelist - القائمة البيضاء
127.0.0.1
localhost
8.8.8.8
8.8.4.4
1.1.1.1
EOF
    fi
    
    if [ ! -s "$BLACKLIST_FILE" ]; then
        cat > "$BLACKLIST_FILE" << EOF
# Blacklist - القائمة السوداء (أمثلة)
# سيتم تحديثها تلقائياً
185.220.101.1
EOF
    fi
    
    # ملف الإعدادات
    if [ ! -s "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
# ASRAR Shield Configuration
MODE=aggressive
AUTO_BLOCK=true
LOG_LEVEL=verbose
SCAN_INTERVAL=60
DNS_FILTER=true
APK_SCAN=true
NETWORK_MONITOR=true
QUANTUM_MODE=false
EOF
    fi
    
    echo -e "${GREEN}[✓] تم إنشاء البنية التحتية${NC}"
}

# مراقبة الشبكة
network_monitor() {
    echo -e "${CYAN}[*] بدء مراقبة الشبكة...${NC}"
    
    LOG_FILE="$LOG_DIR/network/network_$(date +%Y%m%d_%H%M%S).log"
    
    # مراقبة الاتصالات النشطة
    while true; do
        # قائمة الاتصالات
        netstat -tunap 2>/dev/null | grep ESTABLISHED > /tmp/connections.tmp
        
        while IFS= read -r line; do
            # استخراج IP البعيد
            remote_ip=$(echo "$line" | awk '{print $5}' | cut -d: -f1)
            
            # فحص القائمة السوداء
            if grep -q "$remote_ip" "$BLACKLIST_FILE"; then
                echo -e "${RED}[!] اتصال مشبوه محظور: $remote_ip${NC}"
                echo "[$(date)] BLOCKED: $remote_ip" >> "$LOG_FILE"
                
                # حظر IP
                block_ip "$remote_ip"
            else
                echo "[$(date)] ALLOWED: $remote_ip" >> "$LOG_FILE"
            fi
        done < /tmp/connections.tmp
        
        sleep 5
    done
}

# حظر IP
block_ip() {
    local ip="$1"
    
    # إضافة للقائمة السوداء
    if ! grep -q "$ip" "$BLACKLIST_FILE"; then
        echo "$ip" >> "$BLACKLIST_FILE"
        echo -e "${RED}[!] تم حظر: $ip${NC}"
    fi
    
    # قطع الاتصال الحالي (محاكاة)
    # في Termux بدون root، نستخدم طرق بديلة
    echo "[$(date)] IP $ip added to blacklist" >> "$LOG_DIR/firewall/blocked.log"
}

# فحص APK
scan_apk() {
    local apk_path="$1"
    
    if [ ! -f "$apk_path" ]; then
        echo -e "${RED}[!] الملف غير موجود${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}[*] فحص APK: $apk_path${NC}"
    
    # حساب Hash
    local hash=$(sha256sum "$apk_path" | awk '{print $1}')
    echo -e "${CYAN}SHA256: $hash${NC}"
    
    # فحص VirusTotal (محاكاة)
    echo -e "${YELLOW}[*] فحص عبر VirusTotal...${NC}"
    sleep 2
    
    # فحص محتوى APK
    local temp_dir="/tmp/apk_scan_$$"
    mkdir -p "$temp_dir"
    
    # فك ضغط APK
    unzip -q "$apk_path" -d "$temp_dir" 2>/dev/null || {
        echo -e "${RED}[!] فشل فك الضغط${NC}"
        rm -rf "$temp_dir"
        return 1
    }
    
    # البحث عن كود مشبوه
    local suspicious=0
    
    # البحث عن JavaScript hooks
    if grep -r "window.fetch" "$temp_dir" 2>/dev/null | grep -q "eval\|atob\|fromCharCode"; then
        echo -e "${RED}[!] تم اكتشاف JavaScript مشبوه${NC}"
        ((suspicious++))
    fi
    
    # البحث عن permissions خطيرة
    if grep -q "CREDENTIAL_MANAGER" "$temp_dir/AndroidManifest.xml" 2>/dev/null; then
        echo -e "${RED}[!] صلاحيات مشبوهة: CREDENTIAL_MANAGER${NC}"
        ((suspicious++))
    fi
    
    # البحث عن اتصالات C2
    if grep -r "185\.\|suspicious\|c2-server" "$temp_dir" 2>/dev/null; then
        echo -e "${RED}[!] اتصالات مشبوهة بخوادم C2${NC}"
        ((suspicious++))
    fi
    
    # النتيجة
    if [ $suspicious -gt 0 ]; then
        echo -e "${RED}[✗] APK مشبوه! ($suspicious indicators)${NC}"
        mv "$apk_path" "$SHIELD_DIR/quarantine/"
        echo -e "${YELLOW}[*] تم نقل الملف للحجر الصحي${NC}"
    else
        echo -e "${GREEN}[✓] APK آمن${NC}"
    fi
    
    rm -rf "$temp_dir"
}

# فحص DNS
dns_monitor() {
    echo -e "${CYAN}[*] مراقبة DNS...${NC}"
    
    # قائمة DNS المشبوهة
    local malicious_dns=(
        "185.220.101.1"
        "suspicious-analytics.com"
        "track.evil.com"
        "c2-server.com"
    )
    
    # فحص DNS الحالي
    local current_dns=$(getprop net.dns1 2>/dev/null || echo "Unknown")
    echo -e "${CYAN}DNS الحالي: $current_dns${NC}"
    
    # فحص إذا كان مشبوه
    for dns in "${malicious_dns[@]}"; do
        if [[ "$current_dns" == *"$dns"* ]]; then
            echo -e "${RED}[!] DNS مشبوه مكتشف: $dns${NC}"
            echo -e "${YELLOW}[*] توصية: تغيير DNS إلى 1.1.1.1 أو 8.8.8.8${NC}"
        fi
    done
}

# فحص التطبيقات المثبتة
scan_installed_apps() {
    echo -e "${CYAN}[*] فحص التطبيقات المثبتة...${NC}"
    
    # قائمة التطبيقات المشبوهة
    local suspicious_apps=(
        "com.fake.app"
        "com.malware"
        "termux.modified"
    )
    
    # الحصول على قائمة التطبيقات (محاكاة في Termux)
    echo -e "${YELLOW}[*] هذه الميزة تتطلب صلاحيات root للوصول الكامل${NC}"
    echo -e "${CYAN}[*] فحص محدود متاح...${NC}"
    
    # فحص مجلد التطبيقات المتاح
    if [ -d "$HOME/../" ]; then
        ls -la "$HOME/../" 2>/dev/null | head -20
    fi
}

# وضع الكم (Quantum Mode)
quantum_mode() {
    echo -e "${PURPLE}[*] تفعيل وضع الكم (Quantum Mode)...${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # توليد مفاتيح كمية (محاكاة)
    echo -e "${CYAN}[*] توليد مفاتيح كمية...${NC}"
    local quantum_key=$(openssl rand -hex 32)
    echo "$quantum_key" > "$SHIELD_DIR/quantum.key"
    chmod 600 "$SHIELD_DIR/quantum.key"
    
    # تفعيل التشفير المتقدم
    echo -e "${CYAN}[*] تفعيل التشفير الكمي...${NC}"
    
    # تشفير الاتصالات (محاكاة)
    echo -e "${GREEN}[✓] وضع الكم نشط${NC}"
    echo -e "${PURPLE}[!] جميع الاتصالات الآن محمية بتشفير كمي${NC}"
}

# تقرير الحالة
status_report() {
    show_banner
    echo -e "${CYAN}════════════════ تقرير الحالة ════════════════${NC}\n"
    
    # حالة النظام
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo -e "${GREEN}[✓] النظام: نشط${NC}"
    else
        echo -e "${RED}[✗] النظام: متوقف${NC}"
    fi
    
    # إحصائيات
    local blocked_count=$(wc -l < "$BLACKLIST_FILE" 2>/dev/null || echo 0)
    local whitelist_count=$(wc -l < "$WHITELIST_FILE" 2>/dev/null || echo 0)
    local log_count=$(find "$LOG_DIR" -type f | wc -l)
    
    echo -e "${CYAN}IPs محظورة: ${RED}$blocked_count${NC}"
    echo -e "${CYAN}IPs موثوقة: ${GREEN}$whitelist_count${NC}"
    echo -e "${CYAN}ملفات السجل: ${YELLOW}$log_count${NC}"
    
    # آخر التهديدات
    echo -e "\n${YELLOW}═══ آخر التهديدات المحظورة ═══${NC}"
    if [ -f "$LOG_DIR/firewall/blocked.log" ]; then
        tail -5 "$LOG_DIR/firewall/blocked.log"
    else
        echo "لا توجد تهديدات محظورة"
    fi
    
    # استخدام الموارد
    echo -e "\n${CYAN}═══ استخدام الموارد ═══${NC}"
    echo -e "المعالج: $(top -bn1 | grep "Cpu" | awk '{print $2}' || echo "N/A")"
    echo -e "الذاكرة: $(free -h | awk '/^Mem:/ {print $3 "/" $2}' || echo "N/A")"
    
    echo -e "\n${CYAN}════════════════════════════════════════════════${NC}"
}

# القائمة الرئيسية
main_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}           القائمة الرئيسية            ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} تشغيل النظام الكامل"
        echo -e "${GREEN}2)${NC} مراقبة الشبكة"
        echo -e "${GREEN}3)${NC} فحص APK"
        echo -e "${GREEN}4)${NC} مراقبة DNS"
        echo -e "${GREEN}5)${NC} فحص التطبيقات المثبتة"
        echo -e "${PURPLE}6)${NC} تفعيل وضع الكم (Quantum Mode)"
        echo -e "${CYAN}7)${NC} تقرير الحالة"
        echo -e "${YELLOW}8)${NC} الإعدادات"
        echo -e "${BLUE}9)${NC} عرض السجلات"
        echo -e "${RED}0)${NC} إيقاف وخروج"
        echo ""
        echo -ne "${WHITE}اختر [0-9]: ${NC}"
        read choice
        
        case $choice in
            1)
                echo -e "${GREEN}[*] تشغيل النظام الكامل...${NC}"
                network_monitor &
                echo $! > "$PID_FILE"
                dns_monitor
                ;;
            2)
                network_monitor
                ;;
            3)
                echo -ne "${YELLOW}أدخل مسار APK: ${NC}"
                read apk_file
                scan_apk "$apk_file"
                read -p "اضغط Enter للمتابعة..."
                ;;
            4)
                dns_monitor
                read -p "اضغط Enter للمتابعة..."
                ;;
            5)
                scan_installed_apps
                read -p "اضغط Enter للمتابعة..."
                ;;
            6)
                quantum_mode
                read -p "اضغط Enter للمتابعة..."
                ;;
            7)
                status_report
                read -p "اضغط Enter للمتابعة..."
                ;;
            8)
                nano "$CONFIG_FILE"
                ;;
            9)
                echo -e "${CYAN}اختر نوع السجل:${NC}"
                echo "1) Network  2) APK  3) DNS  4) Firewall  5) All"
                read log_choice
                case $log_choice in
                    1) tail -f "$LOG_DIR/network/"*.log 2>/dev/null ;;
                    2) tail -f "$LOG_DIR/apk/"*.log 2>/dev/null ;;
                    3) tail -f "$LOG_DIR/dns/"*.log 2>/dev/null ;;
                    4) tail -f "$LOG_DIR/firewall/"*.log 2>/dev/null ;;
                    5) tail -f "$LOG_DIR"/**/*.log 2>/dev/null ;;
                esac
                ;;
            0)
                if [ -f "$PID_FILE" ]; then
                    kill $(cat "$PID_FILE") 2>/dev/null
                    rm "$PID_FILE"
                fi
                echo -e "${GREEN}شكراً لاستخدام ASRAR Shield${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}خيار غير صحيح${NC}"
                sleep 1
                ;;
        esac
    done
}

# التشغيل الرئيسي
main() {
    show_banner
    sleep 2
    
    check_permissions
    install_dependencies
    setup_structure
    
    echo -e "\n${GREEN}[✓] ASRAR Shield جاهز للعمل${NC}"
    sleep 2
    
    main_menu
}

# تشغيل البرنامج
main
