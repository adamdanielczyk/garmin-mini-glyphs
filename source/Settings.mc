import Toybox.Application.Properties;

class Settings {
    private var settings;

    function initialize() {
        settings = {
            "EnableSleepModeLayout" => Properties.getValue("EnableSleepModeLayout"),
            "UseCustomColors" => Properties.getValue("UseCustomColors"),
            "PresetColor" => Properties.getValue("PresetColor"),
            "RedHighlightColor" => Properties.getValue("RedHighlightColor"),
            "GreenHighlightColor" => Properties.getValue("GreenHighlightColor"),
            "BlueHighlightColor" => Properties.getValue("BlueHighlightColor"),
            "RedRegularColor" => Properties.getValue("RedRegularColor"),
            "GreenRegularColor" => Properties.getValue("GreenRegularColor"),
            "BlueRegularColor" => Properties.getValue("BlueRegularColor"),
        };
    }

    function get(key) {
        return settings[key];
    }
}
