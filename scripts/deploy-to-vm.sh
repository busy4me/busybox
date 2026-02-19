#!/bin/bash
# deploy-to-vm.sh — Hot-reload busybox code onto a running dev VM
# Usage: ./scripts/deploy-to-vm.sh [--host LAB1_HOST] [--port VM_SSH_PORT] [--test]
set -euo pipefail

LAB1_HOST="${LAB1_HOST:-root@lab1.netol.io}"  # jump host
VM_PORT="${VM_PORT:-2201}"                      # NAT port forward on lab1
VM_TARGET="root@localhost"
BUSYBOX_DIR="/opt/busybox"
LOCAL_SRC="$(cd "$(dirname "$0")/.." && pwd)/opt/busybox"
RUN_TESTS=0

for arg in "$@"; do  # parse args
    case "$arg" in
        --host=*) LAB1_HOST="${arg#*=}" ;;
        --port=*) VM_PORT="${arg#*=}" ;;
        --test)   RUN_TESTS=1 ;;
    esac
done

log() { echo "[deploy] $*"; }
die() { echo "[ERROR] $*" >&2; exit 1; }

[ -d "$LOCAL_SRC" ] || die "Local source not found: $LOCAL_SRC"

log "Target: $LAB1_HOST → ssh -p $VM_PORT $VM_TARGET:$BUSYBOX_DIR"
log "Source: $LOCAL_SRC"

# 1. Verify VM is reachable via jump host
ssh -A -o StrictHostKeyChecking=no "$LAB1_HOST" \
    "ssh -o StrictHostKeyChecking=no -p $VM_PORT $VM_TARGET 'echo VM_OK'" \
    | grep -q "VM_OK" || die "Cannot reach VM via jump host"
log "VM reachable ✓"

# 2. Stop busybox service on VM (graceful, ignore if not running)
log "Stopping busybox service..."
ssh -A "$LAB1_HOST" \
    "ssh -p $VM_PORT $VM_TARGET 'systemctl stop busybox.service 2>/dev/null || true; sleep 1'"
log "Service stopped ✓"

# 3. Sync code via tar|ssh pipeline (avoids rsync version/jump-host issues)
log "Syncing code..."
tar -czf - \
    --exclude '.git' --exclude '__pycache__' --exclude '*.pyc' \
    --exclude 'data' --exclude 'log' --exclude 'tmp' \
    --no-xattrs 2>/dev/null \
    -C "$LOCAL_SRC" . \
| ssh -A -o StrictHostKeyChecking=no "$LAB1_HOST" \
    "ssh -o StrictHostKeyChecking=no -p $VM_PORT $VM_TARGET \
     'mkdir -p $BUSYBOX_DIR && tar -xzf - -C $BUSYBOX_DIR'"
log "Code synced ✓"

# 4. Fix permissions on VM
ssh -A "$LAB1_HOST" \
    "ssh -p $VM_PORT $VM_TARGET 'chown -R busybox:busybox $BUSYBOX_DIR && chmod -R u+x $BUSYBOX_DIR/plugins $BUSYBOX_DIR/locate $BUSYBOX_DIR/busybox 2>/dev/null || true'"
log "Permissions fixed ✓"

# 5. Run tests or restart service
if [ "$RUN_TESTS" -eq 1 ]; then
    log "Running tests..."
    ssh -A "$LAB1_HOST" \
        "ssh -p $VM_PORT $VM_TARGET 'cd $BUSYBOX_DIR && /opt/venv/bin/pytest tests/ -v 2>&1'" \
        && log "Tests PASSED ✓" || { log "Tests FAILED ✗"; exit 1; }
else
    log "Restarting busybox service..."
    ssh -A "$LAB1_HOST" \
        "ssh -p $VM_PORT $VM_TARGET 'systemctl start busybox.service 2>/dev/null || true'"
    log "Service started ✓"
fi

log "Deploy complete."
