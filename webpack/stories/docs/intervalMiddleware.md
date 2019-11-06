# Interval Middleware

To start an interval, you should trigger a "startInterval" action from IntervalMiddlware.
"startInterval" is defined in 'webpack/assets/javascripts/react_app/redux/middlewares/IntervalMiddleware'
or 'foremanReact/redux/middlewares/IntervalMiddleware' for plugins:

```js
// MyComponent/MyComponentActions.js
....
import { startInterval } from '../../redux/middlewares/IntervalMiddleware';
...

// use a special key which will be stored to clear the interval.
export const startPolling = () => startInterval(key, callback, interval);
```

There are several ways to stop the interval:

We will need to use the "stopInterval" Action from IntervalMiddlware.
"stopInterval" is defined in 'webpack/assets/javascripts/react_app/redux/middlewares/IntervalMiddleware'
or 'foremanReact/redux/middlewares/IntervalMiddleware' for plugins
```js
// MyComponent/MyComponentActions.js
....
import { stopInterval } from '../../redux/middlewares/IntervalMiddleware';
...

// use the same key you used to start the interval.
export const stopPolling = () => stopInterval(key);
```

Then it will be available in your component:
```js
// MyComponent/MyComponent.js
handlePolling = () => {
  // use the same key you used to start the interval.
  this.props.stopPolling(key) 
}
```

Another option is to add the action to redux "connect" in the index file through "mapDispatchToProps":
```js
// MyComponent/index.js
import { stopInterval } from "../../redux/middlewares/IntervalMiddleware";
// import { stopInterval } from "foremanReact/redux/middlewares/IntervalMiddleware"; in plugins
...
const mapDispatchToProps = dispatch => bindActionCreators( { ...actions, stopInterval }, dispatch)
```

Then it will be available in your component:
```js
// MyComponent/MyComponent.js
handlePolling = () => {
  const { stopInterval } = this.props;
  // use the same key you used to start the interval.
  stopInterval(key) 
}
```

You could also call it with "useDispatch" hook:
```js
// MyComponent/MyComponent.js
import { useDispatch } from 'react-redux'
import { stopInterval } from "../../redux/middlewares/IntervalMiddleware";
// import { stopInterval } from "foremanReact/redux/middlewares/IntervalMiddleware"; in plugins
...
handlePolling = () => {
  const dispatch = useDispatch()
  // use the same key you used to start the interval.
  dispatch(stopInterval(key))
}
```