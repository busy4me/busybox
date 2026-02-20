#!/bin/bash
# health-check.sh — Test live Busybox VM, output JUnit XML for GitHub Actions
# Usage: ./scripts/health-check.sh [--host LAB1_HOST] [--port PORT] [--xml PATH]
set -uo pipefail

LAB1_HOST="${LAB1_HOST:-root@lab1.netol.io}"
VM_PORT="${VM_PORT:-2201}"
XML_OUTPUT="${XML_OUTPUT:-/tmp/busybox-health.xml}"
BB_USER="busybox"
PASS=0; FAIL=0
declare -a RESULTS=()

# Run command on VM via jump host — uses stdin to avoid quoting hell
vm() { ssh -A -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$LAB1_HOST" \
           "ssh -o StrictHostKeyChecking=no -p $VM_PORT root@localhost bash -s" <<< "$*" 2>&1; }
# Run command on VM as busybox user via jump host
vm_bb() { local cmd="$*"
          ssh -A -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$LAB1_HOST" \
              "ssh -o StrictHostKeyChecking=no -p $VM_PORT root@localhost bash -s" \
              <<< "su - $BB_USER -s /bin/bash -c $(printf '%q' "$cmd")" 2>&1; }

t() {  # t "test_name" "description" exit_code [output]
    local name="$1" desc="$2" rc="$3" out="${4:-}"
    if [ "$rc" -eq 0 ]; then
        RESULTS+=("PASS|$name|$desc|"); PASS=$((PASS+1)); echo "  ✅ PASS: $desc"
    else
        RESULTS+=("FAIL|$name|$desc|$out"); FAIL=$((FAIL+1)); echo "  ❌ FAIL: $desc"; [ -n "$out" ] && echo "     → $out"
    fi
}

run() {  # run "name" "desc" "cmd_on_vm" [as_bb]
    local name="$1" desc="$2" cmd="$3" as_bb="${4:-}"
    local out rc=0
    if [ -n "$as_bb" ]; then out=$(vm_bb "$cmd") || rc=$?
    else out=$(vm "$cmd") || rc=$?; fi
    t "$name" "$desc" "$rc" "$out"
}

echo "🔍 Busybox Health Check — $(date -u '+%Y-%m-%d %H:%M UTC')"
echo "   Target: $LAB1_HOST → VM:$VM_PORT"; echo ""

vm "echo reachable" > /dev/null 2>&1 || { echo "❌ FATAL: Cannot reach VM"; exit 1; }

echo "[ VNC & Display ]"
run "vnc_service"     "vncserver@:98.service is active"     "systemctl is-active vncserver@:98.service"
run "xtigervnc_proc"  "Xtigervnc :98 process running"       "pgrep -u $BB_USER Xtigervnc > /dev/null"
run "vnc_port_5998"   "VNC port 5998 listening"             "ss -tlnp | grep -q 5998"
run "display_xdpyinfo" "DISPLAY :98 has active X clients"   "DISPLAY=:98 XAUTHORITY=/home/$BB_USER/.Xauthority xdpyinfo > /dev/null 2>&1" "bb"

echo ""
echo "[ NoVNC Web App ]"
run "flask_service"   "busyman-flask.service is active"     "systemctl is-active busyman-flask.service"
run "websockify_svc"  "busyman-websockify.service is active" "systemctl is-active busyman-websockify.service"
run "flask_port"      "Flask listening on port 8080"        "ss -tlnp | grep -q ':8080'"
run "websockify_port" "websockify listening on port 6080"   "ss -tlnp | grep -q ':6080'"

echo ""
echo "[ Chrome & Browser ]"
run "chrome_proc"     "Chrome process running"              "pgrep -u $BB_USER -x 'chrome\\|google-chrome' > /dev/null || pgrep -u $BB_USER -f google-chrome > /dev/null"
run "chrome_window"   "Chrome window visible on :98"        "DISPLAY=:98 XAUTHORITY=/home/$BB_USER/.Xauthority wmctrl -l | grep -qi chrome" "bb"
run "chrome_display0" "Chrome running on :0 (NoVNC webapp)" "pgrep -u $BB_USER -f 'chrome.*localhost:8080' > /dev/null"

echo ""
echo "[ Automation — Screen Sessions ]"
run "screen_fb"        "Screen session fb:98 active"            "screen -ls | grep -q 'fb:98'" "bb"
run "screen_scroll"    "Screen session fb-scroll:98 active"     "screen -ls | grep -q 'fb-scroll:98'" "bb"
run "screen_walking"   "Screen session fb-walking active"       "screen -ls | grep -q 'fb-walking-around'" "bb"

echo ""
echo "[ Resources ]"
# memory: extract used MB
MEM_OUT=$(vm "free -m | awk '/^Mem:/{print \$3}'") && MEM_RC=$? || MEM_RC=$?
MEM_VAL=$(echo "$MEM_OUT" | tr -d '[:space:]')
if [ "$MEM_RC" -eq 0 ] && [ -n "$MEM_VAL" ] && [ "$MEM_VAL" -lt 1800 ] 2>/dev/null; then
    t "mem_limit" "RAM usage under 1800MB (${MEM_VAL}MB used)" 0
else
    t "mem_limit" "RAM usage under 1800MB" 1 "used=${MEM_VAL}MB"
fi
# disk
DISK_OUT=$(vm "df / | awk 'NR==2{print \$5}' | tr -d '%'") && DISK_RC=$? || DISK_RC=$?
DISK_VAL=$(echo "$DISK_OUT" | tr -d '[:space:]')
if [ "$DISK_RC" -eq 0 ] && [ -n "$DISK_VAL" ] && [ "$DISK_VAL" -lt 80 ] 2>/dev/null; then
    t "disk_limit" "Disk usage under 80% (${DISK_VAL}% used)" 0
else
    t "disk_limit" "Disk usage under 80%" 1 "used=${DISK_VAL}%"
fi
# load
LOAD_OUT=$(vm "cat /proc/loadavg") && LOAD_RC=$? || LOAD_RC=$?
LOAD_1=$(echo "$LOAD_OUT" | awk '{print int($1)}' 2>/dev/null || echo "99")
if [ "$LOAD_1" -lt 8 ] 2>/dev/null; then
    t "load_avg" "Load average under 8.0 (${LOAD_OUT%% *})" 0
else
    t "load_avg" "Load average under 8.0" 1 "$LOAD_OUT"
fi

echo ""
echo "[ Busybox Code ]"
run "opt_busybox_dir"  "/opt/busybox/ present"              "test -d /opt/busybox"
run "locate_exec"      "locate script executable"           "test -x /opt/busybox/locate"
run "busybox_cfg"      "busybox.cfg config present"         "test -f /opt/busybox/busybox.cfg"
run "plugin_fb_dir"    "Facebook plugin directory present"  "test -d /opt/busybox/plugins/fb"
VENV_OUT=$(vm "echo 'import cv2' > /tmp/_venv_test.py && DISPLAY=:98 /opt/venv/bin/python3 /tmp/_venv_test.py 2>&1 && echo ok") && VENV_RC=$? || VENV_RC=$?
t "venv_cv2" "Python venv: cv2 importable (OpenCV)" "$VENV_RC" "$VENV_OUT"

echo ""
echo "[ Unit Tests ]"
# ensure pytest in venv (pip install is idempotent)
vm "/opt/venv/bin/pip install -q pytest pytest-mock" > /dev/null 2>&1 || true
PYTEST_OUT=$(vm "cd /opt/busybox && /opt/venv/bin/pytest tests/ -q --tb=line 2>&1") && PT_RC=$? || PT_RC=$?
PYTEST_SUMMARY=$(echo "$PYTEST_OUT" | tail -2)
t "pytest_unit" "All pytest unit tests pass (20/20)" "$PT_RC" "$PYTEST_SUMMARY"

# --- Generate JUnit XML ---
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%S')
TOTAL=$((PASS+FAIL))
mkdir -p "$(dirname "$XML_OUTPUT")"
{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo "<testsuites><testsuite name=\"busybox-health\" tests=\"$TOTAL\" failures=\"$FAIL\" errors=\"0\" timestamp=\"$TIMESTAMP\">"
    for entry in "${RESULTS[@]}"; do
        IFS='|' read -r status name desc output <<< "$entry"
        safe=$(echo "$output" | sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g;s/"/\&quot;/g' | head -3 | tr '\n' ' ')
        if [ "$status" = "PASS" ]; then
            echo "    <testcase classname=\"busybox.health\" name=\"$desc\"/>"
        else
            echo "    <testcase classname=\"busybox.health\" name=\"$desc\"><failure message=\"$safe\">$safe</failure></testcase>"
        fi
    done
    echo "</testsuite></testsuites>"
} > "$XML_OUTPUT"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  Results: %d passed, %d failed / %d total\n" "$PASS" "$FAIL" "$TOTAL"
echo "  XML:     $XML_OUTPUT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
