import Toybox.Application;
import Toybox.System;

class ConfigurationProvider {

    var font;
    var highlightColor;
    var regularColor;

    function initialize() {
        loadFont();
        loadColors();
    }
    
    function getCurrentTime() {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        var minutes = clockTime.min;

        if (minutes >= 33) {
            hour = hour + 1;
        }

        hour = hour % 12;
        if (hour == 0) {
            hour = 12;
        }

        var minutesRemainder = minutes % 5;
        if (minutesRemainder < 3) {
            minutes = minutes - minutesRemainder;
        } else {
            minutes = minutes + 5 - minutesRemainder;
        }

        minutes = minutes % 60;

        return {
            :hour => hour,
            :minutes => minutes 
        };
    }

    private function loadFont() {
        font = WatchUi.loadResource(Rez.Fonts.Inconsolata);
    }

    private function loadColors() {
        var highlightRgb;
        var regularRgb;

        var useCustomColors = Application.Properties.getValue("UseCustomColors");

        if (useCustomColors) {
            highlightRgb = new Rgb(
                Application.Properties.getValue("RedHighlightColor"),
                Application.Properties.getValue("GreenHighlightColor"),
                Application.Properties.getValue("BlueHighlightColor") 
            );

            regularRgb = new Rgb(
                Application.Properties.getValue("RedRegularColor"),
                Application.Properties.getValue("GreenRegularColor"),
                Application.Properties.getValue("BlueRegularColor") 
            );
        } else {
            var presetColor = Application.Properties.getValue("PresetColor");
            switch (presetColor) {
                default:
                case Blue:
                    highlightRgb = new Rgb(102, 204, 255);
                    regularRgb = new Rgb(30, 59, 74);
                    break;
                case Green:
                    highlightRgb = new Rgb(51, 204, 51);
                    regularRgb = new Rgb(20, 82, 20);
                    break;
                case Grey:
                    highlightRgb = new Rgb(128, 128, 128);
                    regularRgb = new Rgb(51, 51, 51);
                    break;
                case Orange:
                    highlightRgb = new Rgb(255, 153, 0);
                    regularRgb = new Rgb(102, 61, 0);
                    break;
                case Pink:
                    highlightRgb = new Rgb(255, 51, 204);
                    regularRgb = new Rgb(84, 17, 67);
                    break;
                case Red:
                    highlightRgb = new Rgb(255, 0, 0);
                    regularRgb = new Rgb(102, 0, 0);
                    break;
                case Yellow:
                    highlightRgb = new Rgb(255, 255, 0);
                    regularRgb = new Rgb(102, 102, 0);
                    break;
            }
        }

        highlightColor = highlightRgb.getHex();
        regularColor = regularRgb.getHex();
    }

    enum {
        Blue,
        Green,
        Grey,
        Orange,
        Pink,
        Red,
        Yellow
    }

    class Rgb {
        private var r;
        private var g;
        private var b;

        function initialize(r, g, b) {
            me.r = r;
            me.g = g;
            me.b = b;
        }

        function getHex() {
            return r & 0x0000FF << 16 | g & 0x0000FF << 8 | b & 0x0000FF;
        }
    }
}