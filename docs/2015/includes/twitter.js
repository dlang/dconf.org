new TWTR.Widget({
  version: 2,
  type: 'search',
  search: '#dconf OR from:D_programming OR @D_programming', // includes all advanced search queries.
  width: 230,
  height: 385,
  interval: 30000,
  rpp: 20,
  title: ' ',
  subject: ' ',
  theme: {
   shell: {
	 background: 'none'
   },
   tweets: {
	 background: 'none',
	 color: 'black',
	 links: '#af3d7b'
   }
  },
  
  features: {
   avatars: false, // defaults to false for profile widget, but true for search & faves widget
   hashtags: true,
   timestamp: true,
   fullscreen: false, // ignores width and height and just goes full screen
   scrollbar: true,
   live: false,
   loop: true,
   behavior: 'default',
   dateformat: 'absolute', // defaults to relative (eg: 3 minutes ago)
   toptweets: true // only for search widget
  }
}).render().start();