import Toybox.Application;
import Toybox.Lang;

// User settings, remembered between runs in the app's object store.
module Settings {

    const PHASE_OPTIONS = [2, 3, 4, 5, 6, 7, 8, 9, 10];
    // 0 = no time limit
    const DURATION_OPTIONS = [0, 5, 10, 15, 20, 30, 45, 60];
    const TAP_OPTIONS = [15, 30, 40];

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
    function tapMs() as Number { return get("tap", 40); }

    function rhythmLabel() as String {
        return inhaleSec() + "/" + exhaleSec();
    }

    function durationLabel(minutes as Number) as String {
        return minutes == 0 ? "volná" : minutes + " min";
    }
}
