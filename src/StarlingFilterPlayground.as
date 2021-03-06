package {
import feathers.system.DeviceCapabilities;

import flash.display.*;
import flash.events.*;
import flash.geom.Rectangle;

import starling.core.Starling;

[SWF(width="800", height="600", frameRate="60", backgroundColor="#000000")]
public class StarlingFilterPlayground extends Sprite {
    private var _starling:Starling;

    public function StarlingFilterPlayground() {
        addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
    }

    public function onAdded(e:Event):void {
        DeviceCapabilities.dpi = 130;
        DeviceCapabilities.screenPixelWidth = 800;
        DeviceCapabilities.screenPixelHeight = 600;

        removeEventListener(Event.ADDED_TO_STAGE, onAdded);
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        this.stage.align = StageAlign.TOP_LEFT;
        Starling.handleLostContext = true;
        _starling = new Starling(UI, this.stage);
        _starling.start();
        stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);
        stage_resizeHandler(null);
    }

    private function stage_resizeHandler(event:Event):void {
        this._starling.stage.stageWidth = this.stage.stageWidth;
        this._starling.stage.stageHeight = this.stage.stageHeight;
        const viewPort:Rectangle = this._starling.viewPort;
        viewPort.width = this.stage.stageWidth;
        viewPort.height = this.stage.stageHeight;
        try {
            this._starling.viewPort = viewPort;
        }
        catch (error:Error) {
            trace(this, error);
        }
    }
}
}
