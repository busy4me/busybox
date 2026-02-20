#!/usr/bin/env python3
"""Unit tests for busyman API module."""
import pytest, sys, os, subprocess
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
import busyman

class TestBusymanMetadata:
    """Test module metadata and imports."""
    def test_version(self):
        assert busyman.__version__ == "1.0.0"
    def test_author(self):
        assert "Dariusz Porczyński" in busyman.__author__
    def test_exports(self):
        expected = ["find_element", "click_element", "move_to_element", "circle_element", "check_file", "accept_cookies", "close_popup", "detect_blocked"]
        assert set(busyman.__all__) == set(expected)

class TestBusymanCheckFile:
    """Test check_file() function."""
    def test_check_file_exists_in_img_path(self):
        """Test check_file() with existing file in IMG_PATH."""
        with patch('os.path.isfile', return_value=True):
            assert busyman.check_file("test.jpg") is True
    def test_check_file_not_exists(self):
        """Test check_file() with non-existing file."""
        with patch('os.path.isfile', return_value=False):
            assert busyman.check_file("nonexistent.jpg") is False
    def test_check_file_relative_path(self):
        """Test check_file() with relative path (e.g., plugins/fb/img/button.png)."""
        with patch('os.path.isfile', return_value=True):
            assert busyman.check_file("plugins/fb/img/button.png") is True

class TestBusymanFindElement:
    """Test find_element() function."""
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_find_element_success(self, mock_run):
        """Test find_element() returns coordinates on success."""
        mock_run.return_value = MagicMock(returncode=0, stdout="COORDS: (640, 480)\n")
        coords = busyman.find_element("test.jpg")
        assert coords == (640, 480)
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_find_element_not_found(self, mock_run):
        """Test find_element() returns None when element not found."""
        mock_run.return_value = MagicMock(returncode=1, stdout="")
        coords = busyman.find_element("test.jpg")
        assert coords is None
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_find_element_with_offset(self, mock_run):
        """Test find_element() with offset parameters."""
        mock_run.return_value = MagicMock(returncode=0, stdout="COORDS: (650, 490)\n")
        coords = busyman.find_element("test.jpg", offx=10, offy=10)
        assert coords == (650, 490)
        mock_run.assert_called_once()  # verify subprocess was called
        args = mock_run.call_args[0][0]  # first positional arg (cmd list)
        assert "--offx" in args and "10" in args
        assert "--offy" in args and "10" in args

class TestBusymanClickElement:
    """Test click_element() function."""
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_click_element_success(self, mock_run):
        """Test click_element() returns True on success."""
        mock_run.return_value = MagicMock(returncode=0, stdout="COORDS: (640, 480)\n")
        result = busyman.click_element("test.jpg")
        assert result is True
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_click_element_not_found(self, mock_run):
        """Test click_element() returns False when element not found."""
        mock_run.return_value = MagicMock(returncode=1, stdout="")
        result = busyman.click_element("test.jpg")
        assert result is False

class TestBusymanMoveToElement:
    """Test move_to_element() function."""
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_move_to_element_success(self, mock_run):
        """Test move_to_element() returns coordinates."""
        mock_run.return_value = MagicMock(returncode=0, stdout="COORDS: (800, 600)\n")
        coords = busyman.move_to_element("test.jpg")
        assert coords == (800, 600)

class TestBusymanCircleElement:
    """Test circle_element() function."""
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_circle_element_success(self, mock_run):
        """Test circle_element() returns True on success."""
        mock_run.return_value = MagicMock(returncode=0, stdout="")
        result = busyman.circle_element("test.jpg")
        assert result is True

class TestBusymanPlatformHelpers:
    """Test platform-agnostic helper functions."""
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_accept_cookies_fb(self, mock_run):
        """Test accept_cookies() for Facebook."""
        mock_run.return_value = MagicMock(returncode=0, stdout="")
        result = busyman.accept_cookies("fb")
        assert result is True
        args = mock_run.call_args[0][0]
        assert "fb-button-allow-all-cookies.jpg" in " ".join(args)  # verify image in command
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_close_popup_fb(self, mock_run):
        """Test close_popup() for Facebook."""
        mock_run.return_value = MagicMock(returncode=0, stdout="")
        result = busyman.close_popup("fb")
        assert result is True
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_detect_blocked_fb_not_blocked(self, mock_run):
        """Test detect_blocked() returns False when not blocked."""
        mock_run.return_value = MagicMock(returncode=1, stdout="")  # element not found
        result = busyman.detect_blocked("fb")
        assert result is False
    @patch('subprocess.run')
    @patch.dict(os.environ, {"DISPLAY": ":98"})
    def test_detect_blocked_fb_blocked(self, mock_run):
        """Test detect_blocked() returns True when blocked message detected."""
        mock_run.return_value = MagicMock(returncode=0, stdout="COORDS: (640, 480)\n")
        result = busyman.detect_blocked("fb")
        assert result is True
    def test_accept_cookies_unknown_platform(self):
        """Test accept_cookies() raises ValueError for unknown platform."""
        with pytest.raises(ValueError, match="Unknown platform"):
            busyman.accept_cookies("unknown")

class TestBusymanEnvironment:
    """Test DISPLAY environment variable requirement."""
    @patch('subprocess.run')
    @patch.dict(os.environ, {}, clear=True)  # clear DISPLAY env var
    def test_run_locate_no_display(self, mock_run):
        """Test _run_locate() raises EnvironmentError when DISPLAY not set."""
        with pytest.raises(EnvironmentError, match="DISPLAY"):
            busyman._run_locate("test.jpg", "move")
