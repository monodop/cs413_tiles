package menus;

import colliders.Quadtree;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;

class QuadTreeVis extends MenuState
{

	private var quadTree:Quadtree;
	private var imgPool:Array<Image>;
	private var visContainer:Sprite;
	
	public function new(rootSprite:Sprite, quadTree:Quadtree) 
	{
		super(rootSprite);
		this.quadTree = quadTree;
	}
	
	override function init() {
		
		imgPool = new Array<Image>();
		visContainer = new Sprite();
		//visContainer.x = 10;
		//visContainer.y = 48;
		//visContainer.scaleX = 16;
		//visContainer.scaleY = 16;
		
		addChild(visContainer);
		
		this.x = 0;
		this.y = 0;
		//this.visible = false;
		rootSprite.addChild(this);
	}
	override function awake() {
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		addChild(visContainer);
		//this.visible = true;
	}
	override function sleep() {
		this.removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
		removeChild(visContainer);
		//this.visible = false;
	}
	override function deinit() {
		this.removeFromParent();
		this.dispose();
	}
	
	function update(event:EnterFrameEvent) {
		visContainer.removeChildren();
		quadTree.getVisualization(visContainer, imgPool);
		parent.setChildIndex(this, parent.numChildren - 1);
	}
	
	override function transitionIn(?callback:Void->Void) { callback(); }
	override function transitionOut(?callback:Void->Void) { callback(); }
	
}