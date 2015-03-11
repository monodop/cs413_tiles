package menus;

import starling.display.Sprite;

// This class is a base object for menus.
class MenuState extends Sprite {
	
	public var rootSprite:Sprite;

	var _menuStatus = EMenuStatus.STOPPED;
	
	public function new(rootSprite:Sprite) {
		this.rootSprite = rootSprite;
		super();
	}
	
	// Called when the menu is first started
	function init() { }
	
	// Called when the menu is stopped after sleep
	function deinit() { }
	
	// Called after the menu is started, or when the menu is unpaused
	function awake() { }
	
	// Called when the menu is paused or stopped
	function sleep() { }
	
	// Initializes the menu if necessary, then unpauses it.
	public function start() {
		
		if (_menuStatus == EMenuStatus.STOPPED) {
			// Initialize the menu
			init();
			_menuStatus = EMenuStatus.SLEEPING;
			
			// Transition in, then wake up the menu
			transitionIn(function() {
				awake();
				_menuStatus = EMenuStatus.AWAKE;
			});
			
		} else {
			
			// Wake up the menu
			awake();
			_menuStatus = EMenuStatus.AWAKE;
			
		}
		
	}
	
	// Stops the menu and deinitializes it
	public function stop() {
		
		if (_menuStatus == EMenuStatus.AWAKE) {
			// Sleep the menu
			sleep();
			_menuStatus = EMenuStatus.SLEEPING;
		}
		
		if (_menuStatus == EMenuStatus.SLEEPING) {
			// Transition out, then stop the menu
			transitionOut(function() {
				deinit();
				_menuStatus = EMenuStatus.STOPPED;
			});
		}
		
	}
	
	// Pauses the menu, calling it's sleep method
	public function pause() {
		
		if (_menuStatus == EMenuStatus.AWAKE) {
			sleep();
			_menuStatus = EMenuStatus.SLEEPING;
		}
		
	}
	
	// override these to add menu transitions. Call callback after any tweening/animation is done
	private function transitionIn(?callback:Void->Void) { callback(); }
	private function transitionOut(?callback:Void->Void) { callback(); }
	
	public function getMenuStatus():EMenuStatus {
		return this._menuStatus;
	}
	
}

enum EMenuStatus {
	STOPPED;
	SLEEPING;
	AWAKE;
}