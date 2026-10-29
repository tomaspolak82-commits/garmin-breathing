import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Test build: verifies tap length, meditation recording and the end signal on the watch.
class BreathApp extends Application.AppBase {

    private var _session as BreathSession?;

    function initialize() {
        AppBase.initialize();
    }

    function onStop(state as Dictionary?) as Void {
        // Do not lose a running session when the app is closed by the system
        if (_session != null) {
            _session.finish(true);
        }
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        _session = new BreathSession();
        var view = new BreathView(_session);
        return [view, new BreathDelegate(_session)];
    }
}
