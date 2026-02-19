#!/usr/bin/env python3
# conftest.py — shared pytest fixtures for Busyman/locate tests
import sys, os, pytest, importlib.util
from unittest.mock import MagicMock, patch

BUSYBOX_DIR = os.path.join(os.path.dirname(__file__), '..')
sys.path.insert(0, BUSYBOX_DIR)  # add opt/busybox to path

def load_locate():
    """Load 'locate' script (no .py extension) as a module."""
    spec = importlib.util.spec_from_file_location("locate", os.path.join(BUSYBOX_DIR, "locate"))
    mod = importlib.util.module_from_spec(spec)
    sys.modules['locate'] = mod
    spec.loader.exec_module(mod)
    return mod

# --- Mock pyautogui (no display needed) ---
mock_pyautogui = MagicMock()
mock_pyautogui.FAILSAFE = False
mock_pyautogui.locateOnScreen = MagicMock()
mock_pyautogui.center = MagicMock(return_value=(400, 300))
mock_pyautogui.moveTo = MagicMock()
mock_pyautogui.click = MagicMock()
mock_pyautogui.easeOutQuad = None
mock_pyautogui.easeInQuad = None
sys.modules['pyautogui'] = mock_pyautogui  # inject before any import

# --- Mock sentry_sdk (no network needed) ---
mock_sentry = MagicMock()
mock_sentry.init = MagicMock()
sys.modules['sentry_sdk'] = mock_sentry

# --- Mock imutils (optional dep) ---
sys.modules['imutils'] = MagicMock()

@pytest.fixture
def mock_pag():
    """Returns the mocked pyautogui module for assertions."""
    mock_pyautogui.reset_mock()
    return mock_pyautogui

@pytest.fixture
def fake_img(tmp_path):
    """Creates a real 10x10 PNG file for path-existence tests."""
    import struct, zlib
    img_dir = tmp_path / "plugins" / "fb" / "img"
    img_dir.mkdir(parents=True)
    img_file = img_dir / "test_element.png"
    def _png_bytes():  # minimal valid 10x10 white PNG
        def chunk(name, data):
            c = zlib.crc32(name + data) & 0xffffffff
            return struct.pack('>I', len(data)) + name + data + struct.pack('>I', c)
        ihdr = struct.pack('>IIBBBBB', 10, 10, 8, 2, 0, 0, 0)
        raw = b''.join(b'\x00' + b'\xff\xff\xff' * 10 for _ in range(10))
        idat = zlib.compress(raw)
        return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'IDAT', idat) + chunk(b'IEND', b'')
    img_file.write_bytes(_png_bytes())
    return tmp_path, img_dir, img_file

@pytest.fixture
def busyman_env(monkeypatch, tmp_path):
    """Sets up a clean busyman execution environment."""
    img_dir = tmp_path / "plugins" / "fb" / "img"
    img_dir.mkdir(parents=True)
    monkeypatch.setenv('BUSYBOX_IMG_PATH', str(img_dir) + '/')
    return tmp_path, img_dir
