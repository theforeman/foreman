# Getting started


## Development setup

Following steps are required to setup a webpack development environment:

1. **Settings**
   There are 2 relevant settings in `config/settings.yml`. At least `webpack_dev_server` should be set to true:
    ```yaml
    # Use the webpack development server?
    # Should be set to true if you want to conveniently develop webpack-processed code.
    # Make sure to run `rake webpack:compile` if disabled.
    :webpack_dev_server: true

    # If you run Foreman in development behind some proxy or use HTTPS you need
    # to enable HTTPS for webpack dev server too, otherwise you'd get mixed content
    # errors in your browser
    :webpack_dev_server_https: true
    ```

2. **Dependencies**
   Make sure you have all npm dependencies up to date:
    `npm install`
   Alternatively you can run the install command with option `--no-optional` which skips packages that aren't required and can save you some space.

3. **Running webpack**
   There are several ways of executing webpack:
   - using [foreman runner](https://github.com/ddollar/foreman): `foreman start` (starts both rails and webpack server)
   - using `script/foreman-start-dev` (starts rails and webpack server)
   - executing rails and webpack processes "manually"
     ```bash
     ./node_modules/.bin/webpack-dev-server \
       --config config/webpack.config.js \
       --port 3808 \
       --public $(hostname):3808
     ```

4. **Additional config**
    Both `foreman start` and `foreman-start-dev` support `WEBPACK_OPTS` environment variable for passing additional options. This is handy for example when you have development setup with Katello and want to use correct certificates.

    An example of such setup:
    ```bash
    ./node_modules/.bin/webpack-dev-server \
      --config config/webpack.config.js \
      --port 3808 \
      --public $(hostname):3808 \
      --https \
      --key /etc/pki/katello/private/katello-apache.key \
      --cert /etc/pki/katello/certs/katello-apache.crt \
      --cacert /etc/pki/katello/certs/katello-default-ca.crt \
      --watch-poll 1000 # only use for NFS https://community.theforeman.org/t/webpack-watch-over-nfs/10922
    ```

    Additionally you can set `NOTIFICATIONS_POLLING` variable to extend the notification polling interval that is 10s by default and can clutter the console.
    ```bash
    NOTIFICATIONS_POLLING=${polling_interval_in_ms}
    ```


## Directory structure

The webpack processed code is placed in the following folder structure:
```
─ webpack/                 ┈ all webpack processed code
   │
   ├─ stories/             ┈ storybook config (this pages)
   ╰─ assets/javascripts/  ┈ es6 code for erb pages, some still contain jQuery
       │
       ╰─ react_app/       ┈ react components and related code
```

More detailed description of a folder structure for components is in chapter [Adding new component](./?selectedKind=Introduction&selectedStory=Adding%20new%20component).
There are still obsolete `redux` folders at some places. They used to be a place for files containing Redux actions and reducers before a standardized folder structure was introduced. We're migrating away from them. Please don't put additional code there.


## Useful tools
There are some useful extensions that can be used on top of the standard browser's developer tools. Their Firefox mutations are available too.
- [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi)
- [Redux DevTools](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd)
