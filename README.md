
**manywiki** is wiki aggregation tool

Check http://manywiki.meteor.com/ for an example.


It's doing the HTTP gets directly from the client. There's almost nothing going on the server at this point.

This also means it requires adding this to your wiki's Apache server settings:

```
Header set Access-Control-Allow-Origin "*"
```

