import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.ActivityRecording;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.Timer;
import Toybox.WatchUi;

enum SessionState {
    STATE_READY,
    STATE_RUNNING,
    STATE_SAVED
}

// Breathing rhythm, vibration cues and FIT recording.
class BreathSession {

    // Fixed rhythm for the test build: 5 s inhale, 5 s exhale
    private const INHALE_SEC = 5;
    private const EXHALE_SEC = 5;

    // Tap lengths to compare on the watch, in milliseconds
    private const TAP_LENGTHS = [40, 80, 150, 300];

    var state as SessionState = STATE_READY;
    var elapsedSec as Number = 0;
    var tapIndex as Number = 1;
    var toneResult as String = "";

    private var _phaseSec as Number = 0;
    private var _inhale as Boolean = true;
    private var _timer as Timer.Timer?;
    private var _recording as ActivityRecording.Session?;

    function initialize() {
    }

    function tapLength() as Number {
        return TAP_LENGTHS[tapIndex] as Number;
    }

    function nextTapLength(step as Number) as Void {
        var count = TAP_LENGTHS.size();
        tapIndex = (tapIndex + step + count) % count;
        tap();
    }

    function respirationRate() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info has :respirationRate) {
            return info.respirationRate;
        }
        return null;
    }

    function start() as Void {
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        _recording = ActivityRecording.createSession({
            :name => "Koherence 5/5",
            :sport => Activity.SPORT_MEDITATION,
            :subSport => Activity.SUB_SPORT_BREATHING
        });
        _recording.start();

        elapsedSec = 0;
        _phaseSec = 0;
        _inhale = true;
        state = STATE_RUNNING;
        tap();

        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 1000, true);
        WatchUi.requestUpdate();
    }

    function onTick() as Void {
        elapsedSec++;
        _phaseSec++;
        var phaseLength = _inhale ? INHALE_SEC : EXHALE_SEC;
        if (_phaseSec >= phaseLength) {
            _phaseSec = 0;
            _inhale = !_inhale;
            tap();
        }
        WatchUi.requestUpdate();
    }

    // Stops the rhythm and saves (or discards) the recording.
    function finish(save as Boolean) as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        if (_recording != null) {
            if (_recording.isRecording()) {
                _recording.stop();
            }
            if (save) {
                _recording.save();
            } else {
                _recording.discard();
            }
            _recording = null;
        }
        if (state == STATE_RUNNING) {
            state = STATE_SAVED;
            endSignal();
        }
        WatchUi.requestUpdate();
    }

    private function tap() as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, tapLength())]);
        }
    }

    // Two long vibrations plus a tone, clearly different from the taps.
    private function endSignal() as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([
                new Attention.VibeProfile(100, 600),
                new Attention.VibeProfile(0, 300),
                new Attention.VibeProfile(100, 600)
            ]);
        }
        if ((Attention has :playTone) && (Attention has :ToneProfile)) {
            Attention.playTone({
                :toneProfile => [
                    new Attention.ToneProfile(2500, 250),
                    new Attention.ToneProfile(3200, 400)
                ]
            });
            toneResult = "ton: ano";
        } else {
            toneResult = "ton: nepodporovano";
        }
    }
}
