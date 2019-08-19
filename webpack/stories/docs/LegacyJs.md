# Legacy JS

Foreman's legacy javascript is based on ruby on rails assets pipeline and located in `assets/javascripts`


### Access webpack javascript
In order to access new js logic in old js files, we created a global object -`tfm`, which contains a set of functions and located in `/webpack/assets/javascripts/bundle.js`
Please use this object instead of using the `window` object directly.

### Observing the store

With `observeStore` you can observe for changes of the store:

```js
 tfm.store.observeStore('notifications.items', tfm.doSomething);
 ```
`observeStore` accepts two parameters:
1. the part of the store to be observed.
2. a function to run when a change is detected.

```js
const doSomething = (items, unsubscribe) => {
  if (items.length) {
    doSomething();
  }
  else {
    unsubscribe();
  }
}

```
This function have two paramteres as well:
1. the observed store.
2. an unsubscribe function to stop the observation (optional).