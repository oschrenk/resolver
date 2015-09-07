# README

Resolve short urls

## Usage

```
bin/resolve http://t.co/qjcIICdk67
```

## Test cases

- Normal redirect `bin/resolve http://t.co/qjcIICdk67`
- Redirect to https `bin/resolve http://t.co/ctZ6WZbbqh`

## Problem cases

```
curl -I https://www.funcaptcha.com/2015/09/02/introducing-funcabbcha/`
```

generates `HTTP/1.1 403 Forbidden`.

It seems that they forbid `HEAD` requests.

Even faking user agent doesn't work

```
curl -A "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" -I "https://www.funcaptcha.com/2015/09/02/introducing-funcabbcha/"
```


