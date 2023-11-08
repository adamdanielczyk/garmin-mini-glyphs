import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class MiniWordsBackground extends WatchUi.Drawable {

    function initialize() {
        Drawable.initialize({ :identifier => "Background" });
    }

    function draw(dc as Dc) as Void {
        // Set the background color then call to clear the screen
        dc.setColor(Graphics.COLOR_TRANSPARENT, Application.Properties.getValue("BackgroundColor") as Number);
        dc.clear();
    }

}
