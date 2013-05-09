
**wikifarmchanges** is a nice one page overview of recent changes of many wikis.

Check http://wikiytchanges.meteor.com/ for an example.


It's doing the HTTP gets directly from the client. There's almost nothing going on the server at this point.

This also means it requires adding this to your wiki's Apache server settings:

```
Header set Access-Control-Allow-Origin "*"
```

