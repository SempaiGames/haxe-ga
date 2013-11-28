haxe-ga
=======

GoogleAnalytics Client API port to Haxe

Implementation of a generic server-side Google Analytics client in Haxe that implements nearly every parameter and tracking feature of the original GA Javascript client.

This project is a port of php-ga (http://code.google.com/p/php-ga/downloads/list), developed by Thomas Bachem.

Use Example:
=======

	var tracker = new googleAnalytics.Tracker('UA-27265081-3', 'testing.sempaigames.com');

	// (could also get unserialized from somewhere)
	var visitor = new googleAnalytics.Visitor();
	visitor.setUserAgent('haXe-ga');
	visitor.setScreenResolution('1024x768');
	visitor.setLocale('es_AR');

	var session = new googleAnalytics.Session();

	// Assemble Page information
	var page = new googleAnalytics.Page('/page.html');
	page.setTitle('My Page');

	// Track page view
	tracker.trackPageview(page, session, visitor);
	
	// DONE! =]


Disclaimer
=======

Google is a registered trademark of Google Inc.
http://unibrander.com/united-states/140279US/google.html

Licence
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


  WebSite: https://github.com/fbricker/haxe-ga
   Author: Federico Bricker
copyright: Copyright (c) 2012 SempaiGames (http://www.sempaigames.com)
