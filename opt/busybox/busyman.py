#!/usr/bin/env python3
"""
Busyman API — BusyBox Computer Vision Translation Layer

Wraps the 'locate' script as an importable Python module via subprocess.
Provides clean API for CV-based screen automation without platform APIs.

Usage:
    from busyman import find_element, click_element, move_to_element
    
    coords = find_element("fb-login-button.jpg")
    if coords:
        click_element("fb-login-button.jpg", offx=10, offy=5)

Note: Requires DISPLAY and XAUTHORITY environment variables to be set.
"""
import os, subprocess, re
from typing import Optional, Tuple

# Paths
LOCATE_SCRIPT = os.path.join(os.path.dirname(__file__), "locate")
IMG_PATH = os.path.join(os.path.dirname(__file__), "data/images")

def _run_locate(image: str, action: str, offx: int = 0, offy: int = 0, verbose: bool = False) -> Tuple[int, str]:
    """Internal: Execute locate script via subprocess."""
    if not os.path.isfile(LOCATE_SCRIPT):
        raise FileNotFoundError(f"locate script not found: {LOCATE_SCRIPT}")
    cmd = [LOCATE_SCRIPT, "-i", image, "-a", action]
    if offx != 0:
        cmd.extend(["--offx", str(offx)])
    if offy != 0:
        cmd.extend(["--offy", str(offy)])
    if verbose:
        cmd.append("-V")
    env = os.environ.copy()
    if "DISPLAY" not in env:
        raise EnvironmentError("DISPLAY environment variable not set")
    result = subprocess.run(cmd, capture_output=True, text=True, env=env)
    return result.returncode, result.stdout

def find_element(image: str, offx: int = 0, offy: int = 0, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Find element on screen using Computer Vision.
    
    Args:
        image: Image filename (e.g., "fb-login-button.jpg") — searched in IMG_PATH
        offx: X-axis offset from center (default: 0)
        offy: Y-axis offset from center (default: 0)
        verbose: Enable debug output (default: False)
    
    Returns:
        (x, y) coordinates if found, None if not found
    
    Example:
        coords = find_element("fb-like-button.png", offx=5, offy=-10)
        if coords:
            print(f"Element found at {coords}")
    """
    rc, output = _run_locate(image, "move", offx, offy, verbose)
    if rc == 0 and output:
        # Parse coordinates from output: "COORDS: (x, y)"
        match = re.search(r'COORDS:\s*\((\d+),\s*(\d+)\)', output)
        if match:
            return (int(match.group(1)), int(match.group(2)))
    return None

def click_element(image: str, offx: int = 0, offy: int = 0, verbose: bool = False) -> bool:
    """
    Find and click element on screen.
    
    Args:
        image: Image filename
        offx: X-axis offset from center
        offy: Y-axis offset from center
        verbose: Enable debug output
    
    Returns:
        True if clicked, False if element not found
    
    Example:
        if click_element("fb-accept-cookies.jpg"):
            print("Cookies accepted")
    """
    rc, _ = _run_locate(image, "click", offx, offy, verbose)
    return rc == 0

def move_to_element(image: str, offx: int = 0, offy: int = 0, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Find element and move mouse to it (without clicking).
    
    Returns:
        (x, y) coordinates if found and moved, None if not found
    """
    return find_element(image, offx, offy, verbose)

def circle_element(image: str, verbose: bool = False) -> bool:
    """
    Draw a visual circle around element (for debugging/visualization).
    
    Returns:
        True if drawn, False if element not found
    """
    rc, _ = _run_locate(image, "circle", 0, 0, verbose)
    return rc == 0

def check_file(image: str) -> bool:
    """
    Verify that image file exists in IMG_PATH or as relative path.
    
    Args:
        image: Image filename (e.g., "test.jpg") or relative path (e.g., "plugins/fb/img/button.png")
    
    Returns:
        True if file exists, False otherwise
    
    Example:
        if not check_file("fb-login-form.jpg"):
            print("ERROR: Missing image template")
    """
    if os.path.isabs(image) or "/" in image:  # relative or absolute path
        img_path = os.path.join(os.path.dirname(LOCATE_SCRIPT), image)
    else:  # just filename, use IMG_PATH
        img_path = os.path.join(IMG_PATH, image)
    return os.path.isfile(img_path)

# Platform-agnostic helper functions
def accept_cookies(platform: str = "fb") -> bool:
    """Accept cookies popup (platform-specific image templates)."""
    patterns = {
        "fb": "fb-button-allow-all-cookies.jpg",
        "yt": "yt-accept-all-button.png",
        "ig": "ig-accept-cookies.png"
    }
    image = patterns.get(platform)
    if not image:
        raise ValueError(f"Unknown platform: {platform}")
    return click_element(image)

def close_popup(platform: str = "fb") -> bool:
    """Close generic popup/modal (platform-specific)."""
    patterns = {
        "fb": "fb-cross-icon-black-cross-grey-circle.png",
        "yt": "yt-close-button.png",
        "ig": "ig-close-x.png"
    }
    image = patterns.get(platform)
    if not image:
        raise ValueError(f"Unknown platform: {platform}")
    return click_element(image)

def detect_blocked(platform: str = "fb") -> bool:
    """Check if account is blocked (returns True if block message detected)."""
    patterns = {
        "fb": "fb-message-you-are-temporarily-blocked.png",
        "yt": "yt-account-suspended.png",
        "ig": "ig-action-blocked.png"
    }
    image = patterns.get(platform)
    if not image:
        raise ValueError(f"Unknown platform: {platform}")
    return find_element(image) is not None

# Module metadata
__version__ = "1.0.0"
__author__ = "Dariusz Porczyński (Visaroy)"
__all__ = [
    "find_element",
    "click_element", 
    "move_to_element",
    "circle_element",
    "check_file",
    "accept_cookies",
    "close_popup",
    "detect_blocked"
]
