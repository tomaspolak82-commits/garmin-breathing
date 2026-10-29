import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PauseMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Pauza"});
        addItem(new WatchUi.MenuItem("Pokračovat", null, "resume", null));
        addItem(new WatchUi.MenuItem("Uložit", null, "save", null));
        addItem(new WatchUi.MenuItem("Zrušit", null, "discard", null));
    }
}

class PauseMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _session as BreathSession;

    function initialize(session as BreathSession) {
        Menu2InputDelegate.initialize();
        _session = session;
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as String;
        if (id.equals("resume")) {
            resume();
        } else if (id.equals("save")) {
            _session.finish(true);
            System.exit();
        } else if (id.equals("discard")) {
            WatchUi.pushView(new WatchUi.Confirmation("Zrušit aktivitu?"), new DiscardDelegate(_session), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    // BACK in the pause menu means "continue", like the built-in activities.
    function onBack() as Void {
        resume();
    }

    private function resume() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        _session.resume();
    }
}

class DiscardDelegate extends WatchUi.ConfirmationDelegate {

    private var _session as BreathSession;

    function initialize(session as BreathSession) {
        ConfirmationDelegate.initialize();
        _session = session;
    }

    function onResponse(value as Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            _session.finish(false);
            System.exit();
        }
        return true;
    }
}
