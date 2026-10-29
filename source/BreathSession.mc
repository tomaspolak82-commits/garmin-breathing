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

    var state as SessionState = STATE_RUNNING;
    var elapsedSec as Number = 0;
    // 0 = no time limit; set to 0 when the user continues after the countdown
    var limitSec as Number;

    private var _inhaleSec as Number;
    private var _exhaleSec as Number;
    private var _tapMs as Number;
    private var _phaseSec as Number = 0;
    private var _inhale as Boolean = true;
    private var _timer as Timer.Timer?;
    private var _recording as ActivityRecording.Session?;

    function initialize() {
        _inhaleSec = Settings.inhaleSec();
        _exhaleSec = Settings.exhaleSec();
        _tapMs = Settings.tapMs();
        limitSec = Settings.durationMin() * 60;
    }

    function start() as Void {
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        _recording = ActivityRecording.createSession({
            :name => "Koherence " + _inhaleSec + "/" + _exhaleSec,
            :sport => Activity.SPORT_MEDITATION,
            :subSport => Activity.SUB_SPORT_BREATHING
        });
        _recording.start();
        tap();
        startTimer();
    }

    function remainingSec() as Number {
        return limitSec - elapsedSec;
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
        if (limitSec > 0 && elapsedSec >= limitSec) {
            limitSec = 0;
        }
        state = STATE_RUNNING;
        _phaseSec = 0;
        _inhale = true;
        if (_recording != null) {
            _recording.start();
        }
        tap();
        startTimer();
    }

    function onTick() as Void {
        elapsedSec++;
        if (limitSec > 0 && elapsedSec >= limitSec) {
            pause();
            endSignal();
            WatchUi.pushView(new PauseMenu(), new PauseMenuDelegate(self), WatchUi.SLIDE_IMMEDIATE);
            return;
        }
        _phaseSec++;
        var phaseLength = _inhale ? _inhaleSec : _exhaleSec;
        if (_phaseSec >= phaseLength) {
            _phaseSec = 0;
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

    private function startTimer() as Void {
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 1000, true);
        WatchUi.requestUpdate();
    }

    private function stopTimer() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    private function tap() as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, _tapMs)]);
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
        }
    }
}
