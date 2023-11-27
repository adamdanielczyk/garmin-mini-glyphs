import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class MiniGlyphsBackground extends WatchUi.Drawable {

    function initialize() {
        Drawable.initialize({ :identifier => "MiniGlyphsBackground" });
    }

    function draw(dc as Dc) as Void {
        // Set the background color then call to clear the screen
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
    }

}
