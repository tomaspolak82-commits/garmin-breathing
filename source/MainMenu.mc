import Toybox.Lang;
import Toybox.WatchUi;

// Start screen: Start plus the four settings, each showing its current value.
class MainMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Koherence"});
        addItem(new WatchUi.MenuItem("Start", null, "start", null));
        addItem(new WatchUi.MenuItem("Nádech", null, "inhale", null));
        addItem(new WatchUi.MenuItem("Výdech", null, "exhale", null));
        addItem(new WatchUi.MenuItem("Délka", null, "duration", null));
        addItem(new WatchUi.MenuItem("Ťuknutí", null, "tap", null));
        refresh();
    }

    function refresh() as Void {
        var duration = Settings.durationMin();
        setSubLabel("start", Settings.rhythmLabel() + " s · " + Settings.durationLabel(duration));
        setSubLabel("inhale", Settings.inhaleSec() + " s");
        setSubLabel("exhale", Settings.exhaleSec() + " s");
        setSubLabel("duration", Settings.durationLabel(duration));
        setSubLabel("tap", Settings.tapMs() + " ms");
    }

    private function setSubLabel(id as String, text as String) as Void {
        var item = getItem(findItemById(id));
        if (item != null) {
            item.setSubLabel(text);
        }
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as MainMenu;

    function initialize(menu as MainMenu) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as String;
        if (id.equals("start")) {
            var session = new BreathSession();
            getApp().session = session;
            WatchUi.pushView(new RunView(session), new RunDelegate(session), WatchUi.SLIDE_IMMEDIATE);
            session.start();
        } else if (id.equals("inhale")) {
            pushOptions("Nádech", id, Settings.PHASE_OPTIONS, Settings.inhaleSec(), " s");
        } else if (id.equals("exhale")) {
            pushOptions("Výdech", id, Settings.PHASE_OPTIONS, Settings.exhaleSec(), " s");
        } else if (id.equals("duration")) {
            pushOptions("Délka", id, Settings.DURATION_OPTIONS, Settings.durationMin(), null);
        } else if (id.equals("tap")) {
            pushOptions("Ťuknutí", id, Settings.TAP_OPTIONS, Settings.tapMs(), " ms");
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // Opens a list of values; unit null means a duration in minutes.
    private function pushOptions(title as String, key as String, options as Array<Number>, current as Number, unit as String?) as Void {
        var menu = new WatchUi.Menu2({:title => title});
        for (var i = 0; i < options.size(); i++) {
            var value = options[i];
            var label = unit == null ? Settings.durationLabel(value) : value + unit;
            menu.addItem(new WatchUi.MenuItem(label, null, value, null));
            if (value == current) {
                menu.setFocus(i);
            }
        }
        WatchUi.pushView(menu, new OptionsDelegate(key, _menu), WatchUi.SLIDE_IMMEDIATE);
    }
}

class OptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var _key as String;
    private var _mainMenu as MainMenu;

    function initialize(key as String, mainMenu as MainMenu) {
        Menu2InputDelegate.initialize();
        _key = key;
        _mainMenu = mainMenu;
    }

    function onSelect(item as MenuItem) as Void {
        Settings.set(_key, item.getId() as Number);
        _mainMenu.refresh();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
