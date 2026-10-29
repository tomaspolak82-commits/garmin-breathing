import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.Timer;
import Toybox.WatchUi;

enum SessionState {
    STATE_RUNNING,
    STATE_PAUSED,
    STATE_DONE
}

// Breathing rhythm, vibration cues and FIT recording.
class BreathSession {

    const RING_COUNT = 4;

    var state as SessionState = STATE_RUNNING;
    // 0 = no time limit; set to 0 when the user continues after the countdown
    var limitSec as Number;

    private var _inhaleMs as Number;
    private var _exhaleMs as Number;
    private var _tapMs as Number;
    // 0 = guide the whole session
    private var _guideSec as Number = 0;
    // Animation needs quarter steps of a phase, otherwise one tick per second is enough
    private var _tickMs as Number;
    private var _elapsedMs as Number = 0;
    private var _phaseMs as Number = 0;
    private var _inhale as Boolean = true;
    private var _timer as Timer.Timer?;
    private var _recording as ActivityRecording.Session?;

    function initialize() {
        _inhaleMs = Settings.inhaleSec() * 1000;
        _exhaleMs = Settings.exhaleSec() * 1000;
        _tapMs = Settings.tapMs();
        _tickMs = Settings.animation() != Settings.ANIMATION_NONE ? 250 : 1000;
        limitSec = Settings.durationMin() * 60;
        var guide = Settings.guidePercent();
        if (limitSec > 0 && guide < 100) {
            _guideSec = limitSec * guide / 100;
        }
    }

    function start() as Void {
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        _recording = ActivityRecording.createSession({
            :name => activityName(),
            :sport => Activity.SPORT_MEDITATION,
            :subSport => Activity.SUB_SPORT_BREATHING
        });
        _recording.start();
        tap();
        startTimer();
    }

    function elapsedSec() as Number {
        return _elapsedMs / 1000;
    }

    function remainingSec() as Number {
        return limitSec - elapsedSec();
    }

    function isInhale() as Boolean {
        return _inhale;
    }

    // 1 to 4 within the current phase, growing in both inhale and exhale.
    function phaseStep() as Number {
        var phaseLength = _inhale ? _inhaleMs : _exhaleMs;
        return _phaseMs * RING_COUNT / phaseLength + 1;
    }

    // Rings grow from 1 to 4 during the inhale and shrink from 4 to 1 during the exhale.
    function rings() as Number {
        return _inhale ? phaseStep() : RING_COUNT + 1 - phaseStep();
    }

    function pause() as Void {
        if (state != STATE_RUNNING) {
            return;
        }
        state = STATE_PAUSED;
        stopTimer();
        if (_recording != null) {
            _recording.stop();
        }
        WatchUi.requestUpdate();
    }

    // Continues the rhythm with a new inhale.
    function resume() as Void {
        if (state != STATE_PAUSED) {
            return;
        }
        if (limitSec > 0 && elapsedSec() >= limitSec) {
            limitSec = 0;
        }
        state = STATE_RUNNING;
        _phaseMs = 0;
        _inhale = true;
        if (_recording != null) {
            _recording.start();
        }
        tap();
        startTimer();
    }

    function onTick() as Void {
        _elapsedMs += _tickMs;
        if (limitSec > 0 && elapsedSec() >= limitSec) {
            pause();
            endSignal();
            WatchUi.pushView(new PauseMenu(self), new PauseMenuDelegate(self), WatchUi.SLIDE_IMMEDIATE);
            return;
        }
        _phaseMs += _tickMs;
        var phaseLength = _inhale ? _inhaleMs : _exhaleMs;
        if (_phaseMs >= phaseLength) {
            _phaseMs = 0;
            _inhale = !_inhale;
            tap();
        }
        WatchUi.requestUpdate();
    }

    // Saves or discards the recording. Safe to call more than once.
    function finish(save as Boolean) as Void {
        stopTimer();
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
        state = STATE_DONE;
    }

    // "Koherence 5/5", or "Koherence 5/5 · vedení 1,5 min" when guidance stops early.
    private function activityName() as String {
        var name = "Koherence " + Settings.rhythmLabel();
        if (_guideSec > 0) {
            var minutes = (_guideSec / 60).toString();
            if (_guideSec % 60 != 0) {
                minutes += ",5";
            }
            name += " · vedení " + minutes + " min";
        }
        return name;
    }

    private function startTimer() as Void {
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), _tickMs, true);
        WatchUi.requestUpdate();
    }

    private function stopTimer() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    private function tap() as Void {
        if (_tapMs == 0 || (_guideSec > 0 && elapsedSec() >= _guideSec)) {
            return;
        }
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, _tapMs)]);
        }
    }

    // One long vibration; Forerunner devices merge vibration patterns into one anyway.
    private function endSignal() as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
        }
    }
}
