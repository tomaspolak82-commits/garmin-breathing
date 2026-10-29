import Toybox.Lang;
import Toybox.WatchUi;

// Start screen: Start plus the settings, each showing its current value.
class MainMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Koherence"});
        addItem(new WatchUi.MenuItem("Start", null, "start", null));
        addItem(new WatchUi.MenuItem("Nádech", null, "inhale", null));
        addItem(new WatchUi.MenuItem("Výdech", null, "exhale", null));
        addItem(new WatchUi.MenuItem("Délka", null, "duration", null));
        addItem(new WatchUi.MenuItem("Vibrace", null, "tap", null));
        addItem(new WatchUi.MenuItem("Vedení", null, "guide", null));
        addItem(new WatchUi.MenuItem("Animace", null, "animation", null));
        refresh();
    }

    function refresh() as Void {
        setSubLabel("start", Settings.rhythmLabel() + " s · " + Settings.valueLabel("duration", Settings.durationMin()));
        setSubLabel("inhale", Settings.valueLabel("inhale", Settings.inhaleSec()));
        setSubLabel("exhale", Settings.valueLabel("exhale", Settings.exhaleSec()));
        setSubLabel("duration", Settings.valueLabel("duration", Settings.durationMin()));
        setSubLabel("tap", Settings.valueLabel("tap", Settings.tapMs()));
        setSubLabel("guide", Settings.valueLabel("guide", Settings.guidePercent()));
        setSubLabel("animation", Settings.valueLabel("animation", Settings.animation() ? 1 : 0));
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
            pushOptions("Nádech", id, Settings.PHASE_OPTIONS, Settings.inhaleSec());
        } else if (id.equals("exhale")) {
            pushOptions("Výdech", id, Settings.PHASE_OPTIONS, Settings.exhaleSec());
        } else if (id.equals("duration")) {
            pushOptions("Délka", id, Settings.DURATION_OPTIONS, Settings.durationMin());
        } else if (id.equals("tap")) {
            pushOptions("Vibrace", id, Settings.TAP_OPTIONS, Settings.tapMs());
        } else if (id.equals("guide")) {
            pushOptions("Vedení", id, Settings.GUIDE_OPTIONS, Settings.guidePercent());
        } else if (id.equals("animation")) {
            pushOptions("Animace", id, Settings.ANIMATION_OPTIONS, Settings.animation() ? 1 : 0);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    private function pushOptions(title as String, key as String, options as Array<Number>, current as Number) as Void {
        var menu = new WatchUi.Menu2({:title => title});
        for (var i = 0; i < options.size(); i++) {
            var value = options[i];
            menu.addItem(new WatchUi.MenuItem(Settings.valueLabel(key, value), null, value, null));
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
