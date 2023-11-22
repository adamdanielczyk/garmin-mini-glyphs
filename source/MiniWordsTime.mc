import Toybox.Application;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

class MiniWordsTime extends WatchUi.Drawable {

    private const EXTRA_ROW = 1;

    private var font;
    private var highlightColor;
    private var regularColor;
    private var allRows;
    private var textsStartingRow;
    private var additionalMarginLeft;

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
        loadRows(dc);

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
        var fontHeight = dc.getFontHeight(font);
        var rowWidth = dc.getTextWidthInPixels(allRows[0], font);

        drawRegularTextBackground(dc, rowWidth, fontHeight, rowCount);
        
        drawHighlightedTextBackground(dc, fontHeight, textsStartingRow, textsStartingRow + 3, minutesMapping, minutes);
        drawHighlightedTextBackground(dc, fontHeight, textsStartingRow + 3, textsStartingRow + 3, separatorsMapping, separator);
        drawHighlightedTextBackground(dc, fontHeight, textsStartingRow + 4, textsStartingRow + 9, hoursMapping, hour);

        for (var i = 0; i < rowCount; i++) {
            drawRowText(dc, allRows[i], i, fontHeight);
        }
    }

    function drawRegularTextBackground(dc, rowWidth, fontHeight, rowCount) {
        dc.setColor(regularColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(additionalMarginLeft, 1, rowWidth, fontHeight * rowCount);
    }

    function drawHighlightedTextBackground(dc, fontHeight, startIndex, endIndex, textMapping, value) {
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
        
        var x = additionalMarginLeft + letterWidth * letterIndex;
        var y = fontHeight * rowIndex + 1;
        
        var letterCount = textToHighlight.length();
        var width = letterWidth * letterCount;

        dc.setColor(highlightColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, width, fontHeight);
    }

    function drawRowText(dc, rowText, rowIndex, fontHeight) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.drawText(additionalMarginLeft, fontHeight * rowIndex, font, rowText, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function loadRows(dc) {
        if (allRows != null) {
            return;
        }

        var letterWidth = dc.getTextWidthInPixels("A", font);
        var fontHeight = dc.getFontHeight(font);

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        var targetRowCount = screenHeight / fontHeight + EXTRA_ROW;
        var targetColumnCount = screenWidth / letterWidth;
        
        additionalMarginLeft = (screenWidth - letterWidth * targetColumnCount) / 2;
        var isRowEndingWithSpace = targetColumnCount % 2 == 0;
        if (isRowEndingWithSpace) {
            additionalMarginLeft = additionalMarginLeft + letterWidth / 2;
        }

        var initialRowCount = initialRowsWithWords.size();
        var rowsToAdd = targetRowCount - initialRowCount;
        var topRandomRowCount = rowsToAdd / 2;
        var bottomRandomRowCount = rowsToAdd - topRandomRowCount;
        textsStartingRow = topRandomRowCount;

        allRows = new [topRandomRowCount];

        for (var i = 0; i < topRandomRowCount; i++) {
            allRows[i] = "";
        }

        allRows.addAll(initialRowsWithWords);

        for (var i = 0; i < bottomRandomRowCount; i++) {
            allRows.add("");
        }

        for (var i = 0; i < targetRowCount; i++) {
            allRows[i] = getFilledRow(allRows[i], targetColumnCount);
        }
    }

    function getFilledRow(initialRow, targetColumnCount) {
        var rowLength = initialRow.length();
        if (rowLength >= targetColumnCount) {
            return initialRow;
        }

        var columnsToAdd = targetColumnCount - rowLength;
        
        var startRandomColumnCount = columnsToAdd / 2;
        var hasNoSpaceForBothLettersAndSpaceAtStart = startRandomColumnCount % 2 != 0;
        if (hasNoSpaceForBothLettersAndSpaceAtStart) {
            startRandomColumnCount = startRandomColumnCount + 1;
        }

        var endRandomColumnCount = columnsToAdd - startRandomColumnCount;

        var startRandomLetters = "";
        var endRandomLetters = "";

        for (var i = 0; i < startRandomColumnCount; i++) {
            var newText;
            if (i % 2 == 0) {
                newText = lowerCaseLetters[getRandom(0, 25)];
            } else {
                newText = " ";
            }

            startRandomLetters = startRandomLetters + newText;
        }

        for (var i = 0; i < endRandomColumnCount; i++) {
            var newText;
            if (i % 2 == 0) {
                newText = lowerCaseLetters[getRandom(0, 25)];
            } else {
                newText = " ";
            }

            endRandomLetters = endRandomLetters + newText;
        }  
        
        var hasInitialLetters = initialRow.length() != 0;        
        if (hasInitialLetters) {
            return startRandomLetters + initialRow + " " + endRandomLetters;
        } else {
            return startRandomLetters + endRandomLetters;
        }
    }

    function getRandom(min, max) {
        return Math.floor(Math.rand() % (max - min + 1)) + min;
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

    private const lowerCaseLetters = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];

    private const initialRowsWithWords = [
        "T E N", // ten
        "Q U A R T E R", // quarter
        "T W E N T Y F I V E", // twenty five
        "H A L F T O P A S T", // half to past
        "F O U R E L E V E N", // four eleven
        "T E N T H R E E O N E", // ten three one
        "S E V E N E I G H T", // seven eight
        "T W E L V E T W O", // twelve two
        "S I X F I V E", // six five
        "N I N E", // nine
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