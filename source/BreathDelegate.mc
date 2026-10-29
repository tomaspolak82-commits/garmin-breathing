import Toybox.Lang;
import Toybox.WatchUi;

// START starts, UP/DOWN change tap length, BACK stops and saves.
class BreathDelegate extends WatchUi.BehaviorDelegate {

    private var _session as BreathSession;

    function initialize(session as BreathSession) {
        BehaviorDelegate.initialize();
        _session = session;
    }

    function onSelect() as Boolean {
        if (_session.state == STATE_READY) {
            _session.start();
        }
        return true;
    }

    function onPreviousPage() as Boolean {
        _session.nextTapLength(-1);
        WatchUi.requestUpdate();
        return true;
    }

    function onNextPage() as Boolean {
        _session.nextTapLength(1);
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        if (_session.state == STATE_RUNNING) {
            _session.finish(true);
            return true;
        }
        // Not running: let the system close the app
        return false;
    }
}
