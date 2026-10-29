import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Black screen, small white text. Test info is shown at the top.
class BreathView extends WatchUi.View {

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

        dc.drawText(w / 2, h * 0.22, Graphics.FONT_XTINY, "tuk " + _session.tapLength() + " ms (nahoru/dolu)", center);

        if (_session.state == STATE_READY) {
            dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, "START = zacit", center);
            return;
        }

        if (_session.state == STATE_SAVED) {
            dc.drawText(w / 2, h * 0.45, Graphics.FONT_SMALL, "Ulozeno", center);
            dc.drawText(w / 2, h * 0.58, Graphics.FONT_XTINY, _session.toneResult, center);
            dc.drawText(w / 2, h * 0.70, Graphics.FONT_XTINY, "ZPET = konec", center);
            return;
        }

        var rate = _session.respirationRate();
        dc.drawText(w / 2, h * 0.32, Graphics.FONT_XTINY, "dech " + (rate != null ? rate.toString() : "--") + "/min", center);
        dc.drawText(w / 2, h * 0.85, Graphics.FONT_XTINY, formatTime(_session.elapsedSec), center);
    }

    private function formatTime(sec as Number) as String {
        return (sec / 60).format("%d") + ":" + (sec % 60).format("%02d");
    }
}
