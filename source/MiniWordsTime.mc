import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;

class MiniWordsTime extends WatchUi.Drawable {
    private var rowsGenerator;
    private var configurationProvider;

    private var marginLeft = 0;
    private var marginTop = 0;

    function initialize() {
        Drawable.initialize({ :identifier => "MiniWordsTime" });
        loadConfiguration();
    }

    function onSettingsChanged() {
        loadConfiguration();
    }

    function loadConfiguration() {
        configurationProvider = new ConfigurationProvider();
    }

    function draw(dc) {
        var rowsData = loadRowsData(dc);

        var currentTime = configurationProvider.getCurrentTime();
        var hour = currentTime[:hour];
        var minutes = currentTime[:minutes];
        var separator = getSeparator(minutes);

        var rows = rowsData[:rows];
        var fontHeight = dc.getFontHeight(configurationProvider.font);

        drawRegularTextBackground(dc);

        drawHighlightedTextBackground(dc, fontHeight, rows, rowsData[:minutesStartRowIndex], rowsData[:minutesEndRowIndex], minutesMapping, minutes);
        drawHighlightedTextBackground(dc, fontHeight, rows, rowsData[:separatorsStartRowIndex], rowsData[:separatorsEndRowIndex], separatorsMapping, separator);
        drawHighlightedTextBackground(dc, fontHeight, rows, rowsData[:hoursStartRowIndex], rowsData[:hoursEndRowIndex], hoursMapping, hour);

        for (var i = 0; i < rows.size(); i++) {
            drawRowText(dc, rows[i], i, fontHeight);
        }
    }

    function drawRegularTextBackground(dc) {
        if (configurationProvider.isSleepTime()) {
            return;
        }

        dc.setColor(configurationProvider.regularColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(marginLeft, marginTop, dc.getWidth(), dc.getHeight());
    }

    function drawHighlightedTextBackground(dc, fontHeight, rows, startIndex, endIndex, textMapping, value) {
        var textToHighlight = textMapping[value];
        var rowIndex = 0;
        var letterIndex = 0;

        for (var i = startIndex; i <= endIndex && i < rows.size(); i++) {
            var rowText = rows[i];
            var index = rowText.find(textToHighlight);

            if (index != null) {
                letterIndex = index;
                rowIndex = i;
                break;
            }
        }

        var letterWidth = dc.getTextWidthInPixels("A", configurationProvider.font);

        var x = marginLeft + letterWidth * letterIndex;
        var y = marginTop + fontHeight * rowIndex;

        var letterCount = textToHighlight.length();
        var width = letterWidth * letterCount;

        dc.setColor(configurationProvider.highlightColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, width, fontHeight);
    }

    function drawRowText(dc, rowText, rowIndex, fontHeight) {
        var x = marginLeft;
        var y = marginTop + fontHeight * rowIndex;

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.drawText(x, y, configurationProvider.font, rowText, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function loadRowsData(dc) {
        if (rowsGenerator != null) {
            return rowsGenerator.getRowsData();
        }

        var letterWidth = dc.getTextWidthInPixels("A", configurationProvider.font);
        var fontHeight = dc.getFontHeight(configurationProvider.font);

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        var targetRowCount = Math.ceil(screenHeight.toFloat() / fontHeight).toNumber();
        var targetColumnCount = Math.ceil(screenWidth.toFloat() / letterWidth).toNumber();

        calculateLeftMargin(screenWidth, letterWidth, targetColumnCount);
        calculateTopMargin(screenHeight, fontHeight, targetRowCount);

        rowsGenerator = new RowsGenerator(targetRowCount, targetColumnCount);
        return rowsGenerator.getRowsData();
    }

    function calculateLeftMargin(screenWidth, letterWidth, targetColumnCount) {
        var rowWidth = letterWidth * targetColumnCount;
        if (rowWidth > screenWidth) {
            marginLeft = (screenWidth - rowWidth) / 2;
        }

        var rowEndsWithSpace = targetColumnCount % 2 == 0;
        if (rowEndsWithSpace) {
            marginLeft = marginLeft + letterWidth / 2;
        }
    }

    function calculateTopMargin(screenHeight, fontHeight, targetRowCount) {
        var columnHeight = targetRowCount * fontHeight;
        if (columnHeight > screenHeight) {
            marginTop = (screenHeight - columnHeight) / 2;
        }
    }

    function getSeparator(minutes) {
        if (minutes == 0) {
            return "";
        } else if (minutes <= 30) {
            return "PAST";
        } else {
            return "TO";
        }
    }

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
        30 => "H A L F",
    };

    private const separatorsMapping = {
        "" => "",
        "PAST" => "P A S T",
        "TO" => "T O",
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
}
