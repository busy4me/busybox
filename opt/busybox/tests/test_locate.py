#!/usr/bin/env python3
# test_locate.py — Unit tests for locate (Busyman CV action engine)
import sys, os, pytest, importlib, importlib.util
from importlib.machinery import SourceFileLoader, ModuleSpec
from unittest.mock import MagicMock, patch

BUSYBOX_DIR = os.path.join(os.path.dirname(__file__), '..')
LOCATE_PATH = os.path.join(BUSYBOX_DIR, "locate")

def _load_locate_fresh():
    """Load 'locate' (no .py ext) via SourceFileLoader, reset pyautogui mock."""
    pag = sys.modules['pyautogui']
    pag.reset_mock()
    pag.moveTo.return_value = None
    pag.click.return_value = None
    if 'locate' in sys.modules:
        del sys.modules['locate']
    loader = SourceFileLoader("locate", LOCATE_PATH)
    spec = ModuleSpec("locate", loader, origin=LOCATE_PATH)
    mod = importlib.util.module_from_spec(spec)
    sys.modules['locate'] = mod
    try:
        loader.exec_module(mod)
    except SystemExit:
        pass  # locate exits on normal completion — expected
    return mod

def _with_img_path(img_dir, func):
    """Run func with busyboxConfig.img_path temporarily set to img_dir."""
    import busyboxConfig as cfg
    orig = cfg.img_path
    cfg.img_path = str(img_dir) + '/'
    try:
        return func()
    finally:
        cfg.img_path = orig


class TestLocateOptions:
    """Test CLI argument parsing in locate.options()."""

    def test_defaults(self):
        """No args → empty img, empty action, zero offsets."""
        mod = _load_locate_fresh()
        verbose, img, action, mouse_start, offx, offy = mod.options([])
        assert img == '' and action == '' and offx == 0 and offy == 0

    def test_img_flag(self):
        """-i logo.png → img='logo.png'."""
        _, img, *_ = _load_locate_fresh().options(['-i', 'logo.png'])
        assert img == 'logo.png'

    def test_action_flag(self):
        """-a click → action='click'."""
        _, _, action, *_ = _load_locate_fresh().options(['-a', 'click'])
        assert action == 'click'

    def test_offset_flags(self):
        """-X 10 -Y -5 → offx=10, offy=-5."""
        _, _, _, _, offx, offy = _load_locate_fresh().options(['-X', '10', '-Y', '-5'])
        assert offx == 10 and offy == -5

    def test_verbose_flag(self):
        """-V → verbose='true'."""
        verbose, *_ = _load_locate_fresh().options(['-V'])
        assert verbose == 'true'

    def test_all_flags_combined(self):
        """All flags together parsed correctly."""
        verbose, img, action, _, offx, offy = _load_locate_fresh().options(
            ['-V', '-i', 'btn.png', '-a', 'move', '-X', '5', '-Y', '10'])
        assert verbose == 'true' and img == 'btn.png' and action == 'move' and offx == 5 and offy == 10


class TestLocateFindElement:
    """Test find_element() with injected module state."""

    def test_element_found_click(self, fake_img):
        """Element found + action=click → moveTo + click called."""
        _, img_dir, _ = fake_img
        pag = sys.modules['pyautogui']
        box = MagicMock()
        pag.locateOnScreen.return_value = box
        pag.center.return_value = (400, 300)
        def run():
            mod = _load_locate_fresh()
            pag.locateOnScreen.return_value = box
            pag.center.return_value = (400, 300)
            mod.img = 'test_element.png'; mod.action = 'click'; mod.offx = 0; mod.offy = 0; mod.verbose = 'false'  # noqa
            mod.find_element()
            assert pag.moveTo.called, "moveTo must be called for click"
            assert pag.click.called, "click must be called"
        _with_img_path(img_dir, run)

    def test_element_found_move(self, fake_img):
        """Element found + action=move → moveTo called, click NOT called."""
        _, img_dir, _ = fake_img
        pag = sys.modules['pyautogui']
        box = MagicMock()
        def run():
            mod = _load_locate_fresh()
            pag.locateOnScreen.return_value = box
            pag.center.return_value = (400, 300)
            mod.img = 'test_element.png'; mod.action = 'move'; mod.offx = 0; mod.offy = 0; mod.verbose = 'false'  # noqa
            mod.find_element()
            assert pag.moveTo.called, "moveTo must be called for move"
            assert not pag.click.called, "click must NOT be called for move"
        _with_img_path(img_dir, run)

    def test_element_not_found_exits_1(self, fake_img):
        """Element not found → SystemExit(1)."""
        _, img_dir, _ = fake_img
        pag = sys.modules['pyautogui']
        def run():
            mod = _load_locate_fresh()
            pag.locateOnScreen.side_effect = Exception("not on screen")
            mod.img = 'test_element.png'; mod.action = 'click'; mod.offx = 0; mod.offy = 0; mod.verbose = 'false'  # noqa
            with pytest.raises(SystemExit) as exc:
                mod.find_element()
            assert exc.value.code == 1
            pag.locateOnScreen.side_effect = None
        _with_img_path(img_dir, run)

    def test_offset_x_applied(self, fake_img):
        """offx=50 → click target x = center_x + 50 (last moveTo call)."""
        _, img_dir, _ = fake_img
        pag = sys.modules['pyautogui']
        box = MagicMock()
        def run():
            mod = _load_locate_fresh()
            pag.locateOnScreen.return_value = box
            pag.center.return_value = (100, 200)
            mod.img = 'test_element.png'; mod.action = 'click'; mod.offx = 50; mod.offy = 0; mod.verbose = 'false'  # noqa
            mod.find_element()
            move_x = pag.moveTo.call_args_list[-1][0][0]  # last call = actual element move
            assert move_x == 150, f"x should be 100+50=150, got {move_x}"
        _with_img_path(img_dir, run)

    def test_offset_y_applied(self, fake_img):
        """offy=25 → click target y = center_y + 25 (last moveTo call)."""
        _, img_dir, _ = fake_img
        pag = sys.modules['pyautogui']
        box = MagicMock()
        def run():
            mod = _load_locate_fresh()
            pag.locateOnScreen.return_value = box
            pag.center.return_value = (100, 200)
            mod.img = 'test_element.png'; mod.action = 'click'; mod.offx = 0; mod.offy = 25; mod.verbose = 'false'  # noqa
            mod.find_element()
            move_y = pag.moveTo.call_args_list[-1][0][1]  # last call = actual element move
            assert move_y == 225, f"y should be 200+25=225, got {move_y}"
        _with_img_path(img_dir, run)


class TestLocateCheckFile:
    """Test check_file() — image existence validation."""

    def test_missing_file_exits_2(self, fake_img):
        """Missing image → SystemExit(2)."""
        _, img_dir, _ = fake_img
        def run():
            mod = _load_locate_fresh()
            mod.img = 'this_does_not_exist.png'; mod.verbose = 'false'  # noqa
            with pytest.raises(SystemExit) as exc:
                mod.check_file()
            assert exc.value.code == 2
        _with_img_path(img_dir, run)

    def test_existing_file_no_raise(self, fake_img):
        """Existing image → no exception raised."""
        _, img_dir, _ = fake_img
        def run():
            mod = _load_locate_fresh()
            mod.img = 'test_element.png'; mod.verbose = 'false'  # noqa
            mod.check_file()  # must not raise
        _with_img_path(img_dir, run)


class TestBusymanContract:
    """Busyman API contract: correct pyautogui calls per action."""

    @pytest.mark.parametrize("action,expect_click", [
        ("click",  True),
        ("move",   False),
        ("circle", False),
    ])
    def test_action_contract(self, fake_img, action, expect_click):
        """Busyman: action → expected pyautogui calls."""
        _, img_dir, _ = fake_img
        pag = sys.modules['pyautogui']
        box = MagicMock()
        def run():
            mod = _load_locate_fresh()
            pag.locateOnScreen.return_value = box
            pag.center.return_value = (300, 400)
            mod.img = 'test_element.png'; mod.action = action; mod.offx = 0; mod.offy = 0; mod.verbose = 'false'  # noqa
            mod.find_element()
            if expect_click:
                assert pag.click.called, f"action={action} MUST call click()"
            else:
                assert not pag.click.called, f"action={action} must NOT call click()"
        _with_img_path(img_dir, run)
