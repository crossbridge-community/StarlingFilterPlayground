package {
import feathers.controls.ScreenNavigator;
import feathers.controls.ScreenNavigatorItem;

import starling.display.Sprite;
import starling.events.Event;

/**
 * A very basic example to create a Button with Feathers.
 */
public class UI extends Sprite {
    private static const MAIN_MENU:String = "mainMenu";
    private static const BUTTON:String = "button";
    private var _navigator:ScreenNavigator;

    /**
     * Constructor.
     */
    public function UI() {
        //we'll initialize things after we've been added to the stage
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }

    /**
     * Where the magic happens.
     */
    protected function addedToStageHandler(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

        _navigator = new ScreenNavigator();
        addChild(_navigator);

        _navigator.addScreen(MAIN_MENU, new ScreenNavigatorItem(UIMain,
                {
                    showButton: BUTTON
                }));

        _navigator.showScreen(MAIN_MENU);
    }
}
}
