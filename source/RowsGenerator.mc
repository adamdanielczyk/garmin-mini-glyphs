import Toybox.Math;

class RowsGenerator {

    private var targetRowCount;
    private var targetColumnCount;

    private var rows;
    private var textsStartingRow;

    function initialize(targetRowCount, targetColumnCount) {
        me.targetRowCount = targetRowCount;
        me.targetColumnCount = targetColumnCount;
    }

    function getRowsData() {
        if (rows != null) {
            return {
                :rows => rows,
                :minutesStartRowIndex => textsStartingRow,
                :minutesEndRowIndex => textsStartingRow + 3,
                :separatorsStartRowIndex => textsStartingRow + 3,
                :separatorsEndRowIndex => textsStartingRow + 3,
                :hoursStartRowIndex => textsStartingRow + 4,
                :hoursEndRowIndex => textsStartingRow + 9
            };
        }

        var initialRowCount = initialRowsWithWords.size();
        var rowsToAdd = targetRowCount - initialRowCount;
        var topRandomRowCount = rowsToAdd / 2;
        var bottomRandomRowCount = rowsToAdd - topRandomRowCount;
        textsStartingRow = topRandomRowCount;

        rows = new [topRandomRowCount];

        for (var i = 0; i < topRandomRowCount; i++) {
            rows[i] = "";
        }

        rows.addAll(initialRowsWithWords);

        for (var i = 0; i < bottomRandomRowCount; i++) {
            rows.add("");
        }

        for (var i = 0; i < targetRowCount; i++) {
            rows[i] = getFilledRow(rows[i], targetColumnCount);
        }

        return {
            :rows => rows,
            :minutesStartRowIndex => textsStartingRow,
            :minutesEndRowIndex => textsStartingRow + 3,
            :separatorsStartRowIndex => textsStartingRow + 3,
            :separatorsEndRowIndex => textsStartingRow + 3,
            :hoursStartRowIndex => textsStartingRow + 4,
            :hoursEndRowIndex => textsStartingRow + 9
        };
    }

    private function getFilledRow(initialRow, targetColumnCount) {
        var rowLength = initialRow.length();
        if (rowLength >= targetColumnCount) {
            return initialRow;
        }

        var columnsToAdd = targetColumnCount - rowLength;
        
        var leftExtraPartColumnCount = columnsToAdd / 2;
        var leftExtraPartDoesNotEndWithSpace = leftExtraPartColumnCount % 2 != 0;
        if (leftExtraPartDoesNotEndWithSpace) {
            leftExtraPartColumnCount = leftExtraPartColumnCount + 1;
        }

        var rightExtraPartColumnCount = columnsToAdd - leftExtraPartColumnCount;

        var leftExtraLetters = getRandomLetters(leftExtraPartColumnCount);
        var rightExtraLetters = getRandomLetters(rightExtraPartColumnCount);
        
        var hasInitialLetters = initialRow.length() > 0;        
        if (hasInitialLetters) {
            return leftExtraLetters + initialRow + rightExtraLetters;
        } else {
            return leftExtraLetters + rightExtraLetters;
        }
    }

    private function getRandomLetters(count) {
        var text = "";
        for (var i = 0; i < count; i++) {
            if (i % 2 == 0) {
                text = text + lowerCaseLetters[getRandom(0, 25)];
            } else {
                text = text + " ";
            }
        }
        return text;
    }

    private function getRandom(min, max) {
        return Math.floor(Math.rand() % (max - min + 1)) + min;
    }

    private const lowerCaseLetters = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];

    private const initialRowsWithWords = [
        "T E N ", // ten
        "Q U A R T E R ", // quarter
        "T W E N T Y F I V E ", // twenty five
        "H A L F T O P A S T ", // half to past
        "F O U R E L E V E N ", // four eleven
        "T E N T H R E E O N E ", // ten three one
        "S E V E N E I G H T ", // seven eight
        "T W E L V E T W O ", // twelve two
        "S I X F I V E ", // six five
        "N I N E ", // nine
    ];
}