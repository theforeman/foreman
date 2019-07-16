
# Using/Adding/updating NPM dependencies

Foreman manage npm dependencies with a seperate project called `@theforeman/vendor` which responsible to deliver 3rd-party modules to foreman and its plugins.
Foreman and its plugins consumes `@theforeman/vendor` project from `npm` in development and from `rpm` in production.

`@theforeman/vendor` lives inside a monorepo together with other foreman javascript tools in a project called [`foreman-js`](https://github.com/theforeman/foreman-js)

[Read more about `@theforeman/vendor`](https://github.com/theforeman/foreman-js/tree/master/packages/vendor)

### Consuming `foreman-js` projects from source (locally)

1. Clone and install the `foreman-js` project on your local machine:
```sh
git clone git@github.com:theforeman/foreman-js.git
cd foreman-js
npm install
```

2. Link `foreman-js` to foreman, go to `foreman` folder and run:
```sh
FOREMAN_JS_LOCATION=<replace with foreman-js location> npm run foreman-js:link
```

> `FOREMAN_JS_LOCATION` default value is `../foreman-js` so if your `foreman-js` project lives there, you don't have to set this variable.

**NOTICE: running `npm install` in `foreman` will replace the linked version of `foreman-js` with the `npm` version.**
