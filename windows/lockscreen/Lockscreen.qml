import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.services
import qs.modules
ShellRoot {
	id: root
	property real animation_time: Appearance.anim_slow
    IpcHandler {
        target: "lockscreen"
        function lock() {
			if (lock.locked) 
				return;
            lock.locked = true
        }
    }

	LockContext {
		id: lockContext

		property Timer delayedUnlock: Timer {
			interval: animation_time
			repeat: false
			onTriggered: lock.locked = false
		}

		onUnlocked: {
			delayedUnlock.start();
		}
	}


	WlSessionLock {
		id: lock
		
		LockSurface {
			context: lockContext
			animation_time: root.animation_time
		}	
	}
}
