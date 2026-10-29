import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Black screen with a small time at the bottom: countdown, or elapsed time without a limit.
class RunView extends WatchUi.View {

    private var _session as BreathSession;

    function initialize(session as BreathSession) {
        View.initialize();
        _session = session;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var center = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

        if (_session.state == STATE_PAUSED) {
            dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, "Pauza", center);
        } else if (Settings.animation() == Settings.ANIMATION_RINGS) {
            drawRings(dc, w, h);
        } else if (Settings.animation() == Settings.ANIMATION_FACE) {
            drawFace(dc, w);
        }

        var sec = _session.limitSec > 0 ? _session.remainingSec() : _session.elapsedSec();
        dc.drawText(w / 2, h * 0.85, Graphics.FONT_XTINY, formatTime(sec), center);
    }

    // Concentric outlines in muted colors: teal while inhaling, amber while exhaling.
    private function drawRings(dc as Dc, w as Number, h as Number) as Void {
        dc.setColor(_session.isInhale() ? 0x1B7F79 : 0xB0651E, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        var step = w * 0.07;
        for (var i = 1; i <= _session.rings(); i++) {
            dc.drawCircle(w / 2, h * 0.45, step * i);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }

    // Face profile as a grey line; arcs inside the head while inhaling, in front of the face while exhaling.
    // Coordinates are designed for a 390 px screen and scaled to the actual one.
    private function drawFace(dc as Dc, w as Number) as Void {
        var scale = w / 390.0;
        dc.setColor(0x8C959F, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        for (var i = 1; i < FACE.size(); i++) {
            var a = FACE[i - 1] as Array<Number>;
            var b = FACE[i] as Array<Number>;
            dc.drawLine(a[0] * scale, a[1] * scale, b[0] * scale, b[1] * scale);
        }

        dc.setColor(_session.isInhale() ? 0x1B7F79 : 0xB0651E, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        var radii = [26, 46, 66, 86];
        // Arcs always grow: air flowing in while inhaling, flowing out while exhaling
        for (var i = 0; i < _session.phaseStep(); i++) {
            var r = radii[i] * scale;
            if (_session.isInhale()) {
                dc.drawArc(218 * scale, 198 * scale, r, Graphics.ARC_COUNTER_CLOCKWISE, 140, 220);
            } else {
                dc.drawArc(222 * scale, 198 * scale, r, Graphics.ARC_COUNTER_CLOCKWISE, 320, 40);
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }

    private const FACE = [[155, 66], [175, 72], [198, 90], [208, 115], [210, 135], [206, 146], [212, 160], [228, 185], [226, 192],
                          [212, 196], [216, 206], [210, 212], [215, 220], [206, 230], [208, 242], [198, 252], [175, 256], [165, 270], [167, 288]];

    private function formatTime(sec as Number) as String {
        return (sec / 60).format("%d") + ":" + (sec % 60).format("%02d");
    }
}

// START/STOP pauses and opens the pause menu. BACK is ignored so a stray press does not end the session.
class RunDelegate extends WatchUi.BehaviorDelegate {

    private var _session as BreathSession;

    function initialize(session as BreathSession) {
        BehaviorDelegate.initialize();
        _session = session;
    }

    function onSelect() as Boolean {
        if (_session.state == STATE_RUNNING) {
            _session.pause();
            WatchUi.pushView(new PauseMenu(_session), new PauseMenuDelegate(_session), WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }

    function onBack() as Boolean {
        return true;
    }
}
