import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class BreathApp extends Application.AppBase {

    var session as BreathSession?;

    function initialize() {
        AppBase.initialize();
    }

    function onStop(state as Dictionary?) as Void {
        // Keep the recorded data when the system closes the app mid-session
        if (session != null) {
            session.finish(true);
        }
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var menu = new MainMenu();
        return [menu, new MainMenuDelegate(menu)];
    }
}

function getApp() as BreathApp {
    return Application.getApp() as BreathApp;
}
