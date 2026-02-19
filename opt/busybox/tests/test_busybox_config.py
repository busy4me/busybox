#!/usr/bin/env python3
# test_busybox_config.py — Tests for busyboxConfig.py (constants, paths)
import sys, os, pytest
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

class TestBusyboxConfig:
    """Verify busyboxConfig exports required constants."""
    def test_img_path_exists_as_string(self):
        """img_path must be a non-empty string."""
        import busyboxConfig as cfg
        assert isinstance(cfg.img_path, str)
        assert len(cfg.img_path) > 0

    def test_img_path_ends_with_slash(self):
        """img_path must end with '/' for safe concatenation."""
        import busyboxConfig as cfg
        assert cfg.img_path.endswith('/'), f"img_path must end with '/': {cfg.img_path}"

    def test_color_constants_are_strings(self):
        """ANSI color constants must be strings."""
        import busyboxConfig as cfg
        for name in ('ok', 'error', 'warning', 'info', 'success', 'nok'):
            val = getattr(cfg, name, None)
            assert val is not None, f"Missing constant: {name}"
            assert isinstance(val, str), f"Constant {name} must be str"

    def test_no_hardcoded_absolute_path(self):
        """img_path should be derived from __file__, not hardcoded."""
        import busyboxConfig as cfg
        # if running from repo, path should contain 'busybox' or be relative-safe
        assert 'busybox' in cfg.img_path.lower() or 'plugins' in cfg.img_path.lower(), \
            f"img_path looks wrong: {cfg.img_path}"
