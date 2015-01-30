haxe-ga
=======

GoogleAnalytics Client API port to Haxe

Implementation of a generic server-side Google Analytics client in Haxe that implements nearly every parameter and tracking feature of the original GA Javascript client.

This project is a port of php-ga (http://code.google.com/p/php-ga/downloads/list), developed by Thomas Bachem.

Simple use Example:
=======

```haxe
// This example uses the Stats class. This class automatically creates and persists for
// you all google analytics required objects so users will keep their statistics identities
// through different sessions.
// It also creates a queue on native platforms (CPP) so tracking will goes on a separate
// thread to avoid slowing down the main Thread while tracking.

import googleAnalytics.Stats;

class SimpleExample {
	function new(){
		Stats.init('UA-27265081-3', 'testing.sempaigames.com');
		// Stats.init('UA-27265081-3', 'testing.sempaigames.com', true); /* in case you want to use SSL connections */
	}

	function trackStuff(){
		// track some page views
		Stats.trackPageview('/page.html','Page Title!');
		Stats.trackPageview('/untitled.html');

		// track some events
		Stats.trackEvent('play','stage-1/level-3','begin');
		Stats.trackEvent('play','stage-2/level-4','win');
	}
}

```

Advanced use Example:
=======

```haxe
// This example uses the original GoogleAnalytics classes.

import googleAnalytics.Visitor;
import googleAnalytics.Tracker;
import googleAnalytics.Session;
import googleAnalytics.Page;

class AdvancedExample {

	private var tracker:Tracker;
	private var visitor:Visitor;
	private var session:Session;

	function new(){
		tracker = new Tracker('UA-27265081-3', 'testing.sempaigames.com');

		// (could also get unserialized from somewhere)
		visitor = new Visitor();
		visitor.setUserAgent('haXe-ga');
		visitor.setScreenResolution('1024x768');
		visitor.setLocale('es_AR');

		session = new Session();
	}

	function trackPageview(){	
		// Assemble Page information
		var page = new googleAnalytics.Page('/page.html');
		page.setTitle('My Page');

		// Track page view
		tracker.trackPageview(page, session, visitor);
	}
}

```

How to Install:
=======

```bash
haxelib install haxe-ga
```

Disclaimer
=======

Google is a registered trademark of Google Inc.
http://unibrander.com/united-states/140279US/google.html

License
=======
http://www.gnu.org/licenses/lgpl.html

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License (LGPL) as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.
  
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
  
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
  
Google is a registered trademark of Google Inc.


WebSite: https://github.com/fbricker/haxe-ga | Author: Federico Bricker | Copyright (c) 2012 SempaiGames (http://www.sempaigames.com)
