package
{
	import feathers.controls.Header;
	import feathers.controls.Check;
	import feathers.controls.Screen;
    import feathers.controls.TextInput;
    import feathers.themes.MetalWorksMobileTheme;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.filters.GLSLFilter;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import flash.text.TextField;
	import flash.text.TextFieldType;

	[Event(name="complete",type="starling.events.Event")]

	public class UIMain extends Screen
	{
		private var _header:Header;
		private var _theme:MetalWorksMobileTheme;

		private var vertexSource:TextInput;
		private var fragmentSource:TextInput;


		// Texture Atlas

        [Embed(source="/../assets/bird_atlas.xml", mimeType="application/octet-stream")]
        public static const AtlasXml:Class;

        [Embed(source="/../assets/bird_atlas.png")]
        public static const AtlasTexture:Class;

        private static var sTextureAtlas:TextureAtlas;

        private var mMovie:MovieClip;

        private var sourceCheck:Check;

        private var glslfilter:GLSLFilter = new GLSLFilter()

        public static function getTextureAtlas():TextureAtlas
        {
            if (sTextureAtlas == null)
            {
                var texture:Texture = Texture.fromBitmap(new AtlasTexture(), true, false, 1);
                var xml:XML = XML(new AtlasXml());
                sTextureAtlas = new TextureAtlas(texture, xml);
            }

            return sTextureAtlas;
        }

		public function UIMain()
		{
			super();
		}

		override protected function initialize():void
		{
			_theme = new MetalWorksMobileTheme(stage);
			_header = new Header();
			_header.title = "Starling Filter Playground";
			addChild(_header);

			sourceCheck = new Check();
			sourceCheck.label = "Display Source";
			sourceCheck.addEventListener(Event.TRIGGERED, sourceCheck_triggeredHandler);
            addChild(sourceCheck);
            sourceCheck.isSelected = true;

			var frames:Vector.<Texture> = getTextureAtlas().getTextures("flight");
            mMovie = new MovieClip(frames, 24);
			addChild(mMovie);
			mMovie.filter = glslfilter;

			Starling.juggler.add(mMovie);

			vertexSource = new TextInput();
			vertexSource.visible = sourceCheck.isSelected;
			vertexSource.isEditable = true;
			vertexSource.addEventListener(Event.CHANGE, vertexSourceChanged);
            addChild(vertexSource);

			fragmentSource = new TextInput();
			fragmentSource.visible = sourceCheck.isSelected;
			fragmentSource.isEditable = true;
			fragmentSource.addEventListener(Event.CHANGE, fragmentSourceChanged);
            addChild(fragmentSource);

			vertexSource.text = <![CDATA[
varying vec2 TexCoords;
void main() {
TexCoords = gl_MultiTexCoord0.xy;
gl_Position = gl_ModelViewProjectionMatrix * vec4(gl_Vertex.xy, 0, 0);
}
]]>;

			fragmentSource.text =  <![CDATA[
varying vec2 TexCoords;
uniform sampler2D baseTexture;
uniform float time;
vec2 wobbleTexCoords(in vec2 tc) {
tc.x += (sin(tc.x*10.0 + time*10.0)*0.05);
tc.y -= (cos(tc.y*10.0 + time*10.0)*0.05);
return tc;
}
void main() {
vec2 tc = wobbleTexCoords(TexCoords);
vec4 oc = texture2D(baseTexture, tc);
gl_FragColor = oc;
}
]]>;

			recompile();
        }

        private function recompile():void
        {
			glslfilter.update(vertexSource.text, fragmentSource.text);
        }

        private function sourceCheck_triggeredHandler(event:Event):void
		{
			vertexSource.visible = !vertexSource.visible;
			fragmentSource.visible = !fragmentSource.visible;
		}

		private function vertexSourceChanged(e:*):void
		{
			recompile();
		}

		private function fragmentSourceChanged(e:*):void
		{
			recompile();
		}

		override protected function draw():void
		{
			_header.width = actualWidth;
			_header.validate();

			sourceCheck.y = _header.height + 5
			sourceCheck.validate();

			vertexSource.y = sourceCheck.y + sourceCheck.height + 5;

			var h:int = stage.stageHeight - vertexSource.y - 10;

			vertexSource.width = stage.stageWidth * 0.5;
			vertexSource.height = h * 0.5;

			fragmentSource.y = vertexSource.y + (h * 0.5) + 10;
			fragmentSource.width = stage.stageWidth * 0.5;
			fragmentSource.height = h * 0.5;

            mMovie.x = (stage.stageWidth * 0.5);
            mMovie.y = (stage.stageHeight * 0.5) - 200;
		}
	}
}