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
        }

        var sec = _session.limitSec > 0 ? _session.remainingSec() : _session.elapsedSec;
        dc.drawText(w / 2, h * 0.85, Graphics.FONT_XTINY, formatTime(sec), center);
    }

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
            WatchUi.pushView(new PauseMenu(), new PauseMenuDelegate(_session), WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }

    function onBack() as Boolean {
        return true;
    }
}
