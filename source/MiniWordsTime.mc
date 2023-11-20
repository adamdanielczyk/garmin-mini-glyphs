import Toybox.Application;
import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;

class MiniWordsTime extends WatchUi.Drawable {

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

        var rowCount = allRows.size();

        var centerY = dc.getHeight() / 2;
        var fontHeight = dc.getFontHeight(font);
        var initialY = centerY - fontHeight * rowCount / 2;
        var rowWidth = dc.getTextWidthInPixels(allRows[0], font);

        drawRegularTextBackground(dc, initialY, rowWidth, fontHeight, rowCount);
        
        drawHighlightedTextBackground(dc, initialY, fontHeight, 3, 5, minutesMapping, minutes);
        drawHighlightedTextBackground(dc, initialY, fontHeight, 5, 5, separatorsMapping, separator);
        drawHighlightedTextBackground(dc, initialY, fontHeight, 6, 11, hoursMapping, hour);

        for (var i = 0; i < rowCount; i++) {
            drawRowText(dc, allRows[i], i, initialY, fontHeight);
        }
    }

    function drawRegularTextBackground(dc, initialY, rowWidth, fontHeight, rowCount) {
        dc.setColor(regularColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, initialY + 1, rowWidth, fontHeight * rowCount);
    }

    function drawHighlightedTextBackground(dc, initialY, fontHeight, startIndex, endIndex, textMapping, value) {
        var textToHighlight = textMapping[value];
        var rowIndex = 0;
        var letterIndex = 0;

        for (var i = startIndex; i <= endIndex && i < allRows.size(); i++) {            
            var rowText = allRows[i];
            var index = rowText.find(textToHighlight);

            if (index != null) {
                letterIndex = index;
                rowIndex = i;
                break;
            }
        }

        var letterWidth = dc.getTextWidthInPixels("A", font);
        
        var x = letterWidth * letterIndex;
        var y = initialY + fontHeight * rowIndex + 1;
        
        var letterCount = textToHighlight.length();
        var width = letterWidth * letterCount;

        dc.setColor(highlightColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, width, fontHeight);
    }

    function drawRowText(dc, rowText, rowIndex, initialY, fontHeight) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.drawText(0, initialY + fontHeight * rowIndex, font, rowText, Graphics.TEXT_JUSTIFY_LEFT);
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

    private const allRows = [
        "K F Y S E A Z Q V X O G H K B P T",
        "T Q L H F Z Q N O K A M Y I C R U",
        "X A U Q J L O E V N O A Y A T V J",
        "K B X T W E N T Y F I V E T Y H Z", // twenty five
        "Z K T Q U A R T E R T E N H R H R", // quarter ten
        "O F L H A L F T O P A S T X M V A", // half to past
        "H J F O U R W O E L E V E N L N D", // four eleven
        "A Y T E N T H R E E I O N E Z T Y", // ten three one
        "S G N S E V E N P E I G H T V G N", // seven eight
        "E F O D R F I V E Z T W O Z D T U", // five two
        "S A B S I X G T W E L V E C F D G", // six twelve
        "G Q G Y K X P N I N E M U K N T J", // nine
        "Z N E X E P V I A E U B D S D D Z",
        "Y K Q F G Z T M H S U A R N X E I",
        "D L T I K B C A W P H Q W L T Y B"
    ];

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