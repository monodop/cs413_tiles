package utility;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import starling.core.Starling;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import utility.ControlManager.ControlAction;

// This class handles control schemes and bindings.
// To use this, register whatever actions you want.
// You can provide default keybindings, but you can also manually bind keys later.
// You can hook functions to actions, so that when an action is activated or deactivated,
// the function is called. Hooks have a key which allow you to deactivate them later by the
// same name. Make sure the key is unique to every callback function you want to use.
// You can also check the activation state of an action using isDown.

// When you create an instance of a controlmanager, you will need to hook the keyDown,
// keyUp, and touchEvents to the associated events in starling so that this class
// stays up to date.
class ControlManager
{
	
	private var actions:StringMap<ControlAction>;
	private var keyBindings:IntMap<String>;
	
	private var mousePos:Point;
	
	public function new() 
	{
		actions = new StringMap<ControlAction>();
		keyBindings = new IntMap<String>();
		mousePos = new Point();
	}
	
	public function registerAction(actionName:String, ?defaultKey:UInt) {
		actions.set(actionName, new ControlAction(actionName));
		
		if (defaultKey != null)
			bindKey(actionName, defaultKey);
	}
	public function deregisterAction(actionName:String) {
		if(actions.exists(actionName))
			actions.remove(actionName);
	}
	
	public function bindKey(actionName:String, key:UInt) {
		keyBindings.set(key, actionName);
	}
	
	public function hook(actionName:String, hookName:String, callback:ControlAction->Void) {
		if (actions.exists(actionName)) {
			var action:ControlAction = actions.get(actionName);
			action.hook(hookName, callback);
		}
	}
	public function unhook(actionName:String, hookName:String) {
		if (actions.exists(actionName)) {
			var action:ControlAction = actions.get(actionName);
			action.unhook(hookName);
		}
	}
	
	public function getAction(actionName:String):ControlAction {
		if (actions.exists(actionName))
			return actions.get(actionName);
		return null;
	}
	public function isDown(actionName:String):Bool {
		if (actions.exists(actionName))
			return actions.get(actionName).isActive();
		return false;
	}
	
	public function getMousePos(): Point {
		return this.mousePos;
	}
	
	public function keyDown(event:KeyboardEvent) {
		if (keyBindings.exists(event.keyCode)) {
			var actionName = keyBindings.get(event.keyCode);
			if (actions.exists(actionName)) {
				var action:ControlAction = actions.get(actionName);
				if(!action.isActive())
					action.activate();
			}
		}
	}
	public function keyUp(event:KeyboardEvent) {
		if (keyBindings.exists(event.keyCode)) {
			var actionName = keyBindings.get(event.keyCode);
			if (actions.exists(actionName)) {
				var action:ControlAction = actions.get(actionName);
				if(action.isActive())
					action.deactivate();
			}
		}
	}
	public function touch(event:TouchEvent) {
		mousePos = Point.fromPoint(event.touches[0].getLocation(Starling.current.stage));
	}
	
}

// Represents a specific action in the control scheme.
class ControlAction {
	
	private var actionName:String;
	private var hooks:StringMap<ControlAction->Void>;
	private var active:Bool;
	
	public function new(actionName:String) {
		
		this.actionName = actionName;
		this.hooks = new StringMap < ControlAction->Void > ();
		this.active = false;
		
	}
	
	// Use this to hook a new event handler to this action.
	public function hook(key:String, func:ControlAction->Void) {
		hooks.set(key, func);
	}
	// Use this to unhook an event handler from this action.
	public function unhook(key:String) {
		if (hooks.exists(key))
			hooks.remove(key);
	}
	
	// This activates the action. Probably don't call this.
	public function activate() {
		this.active = true;
		notifyAll();
	}
	// This deactivates the action. Probably don't call this either.
	public function deactivate() {
		this.active = false;
		notifyAll();
	}
	
	// Checks if the action is activated.
	public function isActive():Bool {
		return this.active;
	}
	
	// Notifies all callback events of this action's status by calling the hooks.
	public function notifyAll() {
		
		for (key in hooks.keys()) {
			var func = hooks.get(key);
			func(this);
		}
		
	}
	
}