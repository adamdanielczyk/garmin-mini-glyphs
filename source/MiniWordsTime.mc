import Toybox.Application;
import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;

class MiniWordsTime extends WatchUi.Drawable {

    private const LEFT_MARGIN = 55;

    private var font;
    private var highlightColor;
    private var regularColor;

    function initialize() {
        Drawable.initialize({ :identifier => "MiniWordsTime" });
        loadConfiguration();
    }

    function onSettingsChanged() {
        loadConfiguration();
    }
        
    function loadConfiguration() {
        loadFont();
        loadColors();
    }

    function loadFont() {
        font = WatchUi.loadResource(Rez.Fonts.Inconsolata);
    }

    function loadColors() {
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
                    regularRgb = new Rgb(230, 247, 255);
                    break;
                case Green:
                    highlightRgb = new Rgb(51, 204, 51);
                    regularRgb = new Rgb(235, 250, 235);
                    break;
                case Grey:
                    highlightRgb = new Rgb(128, 128, 128);
                    regularRgb = new Rgb(230, 230, 230);
                    break;
                case Orange:
                    highlightRgb = new Rgb(255, 153, 0);
                    regularRgb = new Rgb(255, 245, 230);
                    break;
                case Pink:
                    highlightRgb = new Rgb(255, 51, 204);
                    regularRgb = new Rgb(255, 230, 249);
                    break;
                case Red:
                    highlightRgb = new Rgb(255, 0, 0);
                    regularRgb = new Rgb(255, 230, 230);
                    break;
                case Yellow:
                    highlightRgb = new Rgb(255, 255, 0);
                    regularRgb = new Rgb(255, 255, 230);
                    break;
            }
        }

        highlightColor = highlightRgb.getHex();
        regularColor = regularRgb.getHex();
    }

    function draw(dc) {
        var currentTime = getCurrentTime();
        var hour = currentTime[:hour];
        var minutes = currentTime[:minutes];        

        var separator;
        if (minutes == 0) {
            separator = "";
        } else if (minutes <= 30) {
            separator = "PAST";
        } else {
            separator = "TO";
        }

        var allRows = minutesRows.values().addAll(hoursRows.values());
        var rowCount = allRows.size();

        var centerY = dc.getHeight() / 2;
        var fontHeight = dc.getFontHeight(font);
        var initialY = centerY - fontHeight * rowCount / 2;
        var rowWidth = dc.getTextWidthInPixels(row0, font);

        drawRegularTextBackground(dc, initialY, rowWidth, fontHeight, rowCount);
        
        drawHighlightedTextBackground(dc, initialY, fontHeight, minutesRows, minutesMapping, minutes);
        drawHighlightedTextBackground(dc, initialY, fontHeight, separatorsRows, separatorsMapping, separator);
        drawHighlightedTextBackground(dc, initialY, fontHeight, hoursRows, hoursMapping, hour);

        for (var i = 0; i < rowCount; i++) {
            drawRowText(dc, allRows[i], i, initialY, fontHeight);
        }
    }

    function drawRegularTextBackground(dc, initialY, rowWidth, fontHeight, rowCount) {
        dc.setColor(regularColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(LEFT_MARGIN, initialY + 1, rowWidth, fontHeight * rowCount);
    }

    function drawHighlightedTextBackground(dc, initialY, fontHeight, rows, textMapping, value) {
        var text = textMapping[value];
        var rowIndex = 0;
        var letterIndex = 0;

        for (var i = 0; i < rows.keys().size(); i++) {
            rowIndex = rows.keys()[i];
            var rowText = rows[rowIndex];
            var index = rowText.find(text);

            if (index != null) {
                letterIndex = index;
                break;
            }
        }

        var letterWidth = dc.getTextWidthInPixels("A", font);
        
        var x = LEFT_MARGIN + letterWidth * letterIndex;
        var y = initialY + fontHeight * rowIndex + 1;
        
        var letterCount = text.length();
        var width = letterWidth * letterCount;

        dc.setColor(highlightColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, width, fontHeight);
    }

    function drawRowText(dc, rowText, rowIndex, initialY, fontHeight) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.drawText(LEFT_MARGIN, initialY + fontHeight * rowIndex, font, rowText, Graphics.TEXT_JUSTIFY_LEFT);
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

    private const row0 = "X T W E N T Y F I V E K"; // twenty five
    private const row1 = "L Q U A R T E R T E N Z"; // quarter ten
    private const row2 = "G H A L F J T O P A S T"; // half to past
    private const row3 = "C F O U R B E L E V E N"; // four eleven
    private const row4 = "V T E N T H R E E O N E"; // ten three one
    private const row5 = "L Y S E V E N E I G H T"; // seven eight
    private const row6 = "N S I X C F I V E T W O"; // six five two
    private const row7 = "P N I N E T W E L V E M"; // nine twelve

    private const minutesRows = {
        0 => row0,
        1 => row1,
        2 => row2
    };

    private const separatorsRows = {
        2 => row2
    };

    private const hoursRows = {
        3 => row3,
        4 => row4,
        5 => row5,
        6 => row6,
        7 => row7
    };

    private const minutesMapping = {
        0 => "",
        5 => "F I V E",
        55 => "F I V E",
        10 => "T E N",
        50 => "T E N",
        15 => "Q U A R T E R",
        45 => "Q U A R T E R",
        20 => "T W E N T Y",
        40 => "T W E N T Y",
        25 => "T W E N T Y F I V E",
        35 => "T W E N T Y F I V E",
        30 => "H A L F"
    };
    
    private const separatorsMapping = {
        "" => "",
        "PAST" => "P A S T",
        "TO" => "T O"
    };

    private const hoursMapping = {
        1 => "O N E",
        2 => "T W O",
        3 => "T H R E E",
        4 => "F O U R",
        5 => "F I V E",
        6 => "S I X",
        7 => "S E V E N",
        8 => "E I G H T",
        9 => "N I N E",
        10 => "T E N",
        11 => "E L E V E N",
        12 => "T W E L V E",
    };

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