# QR+Copy

![QR+Copy logo](public/qr-copy-resized.png)

Transfer text and files between devices using p2p communication.

Live application: https://mark-gerarts.github.io/qr-copy/

## Development

Installation:

```console
$ npm ci
```

Run a local development server with live reload:

```console
$ npm run dev
```

Build the CSS:

```console
$ npm run css-deploy
```

Other useful commands can be found in `package.json`.

## Open issues

- [ ] Better error handling when connection fails
- [ ] ...or even automatic reconnect if possible
- [ ] Tests
- [ ] Only start sending text after a small delay
- [ ] Warning for big files
- [ ] Add extended help
