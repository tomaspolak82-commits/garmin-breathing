import Toybox.Application;
import Toybox.Lang;

// User settings, remembered between runs in the app's object store.
module Settings {

    const PHASE_OPTIONS = [2, 3, 4, 5, 6, 7, 8, 9, 10];
    // 0 = no time limit
    const DURATION_OPTIONS = [0, 5, 10, 15, 20, 30, 45, 60];
    // 0 = vibration off
    const TAP_OPTIONS = [0, 15, 30, 40];
    // Share of the countdown with vibration guidance, in percent; 100 = whole session
    const GUIDE_OPTIONS = [100, 10, 30, 50];
    const ANIMATION_OPTIONS = [0, 1];

    function get(key as String, fallback as Number) as Number {
        var value = Application.Storage.getValue(key);
        return value instanceof Number ? value : fallback;
    }

    function set(key as String, value as Number) as Void {
        Application.Storage.setValue(key, value);
    }

    function inhaleSec() as Number { return get("inhale", 5); }
    function exhaleSec() as Number { return get("exhale", 5); }
    function durationMin() as Number { return get("duration", 10); }
    function tapMs() as Number { return get("tap", 15); }
    function guidePercent() as Number { return get("guide", 100); }
    function animation() as Boolean { return get("animation", 0) == 1; }

    function rhythmLabel() as String {
        return inhaleSec() + "/" + exhaleSec();
    }

    // Text shown in the menu for a stored value.
    function valueLabel(key as String, value as Number) as String {
        if (key.equals("inhale") || key.equals("exhale")) {
            return value + " s";
        } else if (key.equals("duration")) {
            return value == 0 ? "volná" : value + " min";
        } else if (key.equals("tap")) {
            return value == 0 ? "Vyp" : value + " ms";
        } else if (key.equals("guide")) {
            return value == 100 ? "celou dobu" : value + " %";
        } else if (key.equals("animation")) {
            return value == 1 ? "Ano" : "Ne";
        }
        return value.toString();
    }
}
