# API Middleware with polling

current generic API action looks like this:

```js
const some_API_action = payload => ({
  type: API_OPERATIONS.GET,
  key: MY_API_REQUEST_SPECIAL_KEY, /** an unique key is required. */
  payload,
});
```

To use polling, we will need to add the "polling" key:

```js
const some_API_action = payload => ({
  type: API_OPERATIONS.GET,
  key: MY_API_REQUEST_SPECIAL_KEY, /** an unique key is required. */
  polling: 3000, /** value in ms, or true which will use the default values. */  
  payload,
});
```
There are several ways to stop the API polling:

We will need to use the "stopInterval" Action from IntervalMiddlware.
"stopInterval" is defined in 'webpack/assets/javascripts/react_app/redux/middlewares/IntervalMiddleware'
or 'foremanReact/redux/middlewares/IntervalMiddleware' for plugins
```js
// MyComponent/MyComponentActions.js
....
import { stopInterval } from '../../middlewares/IntervalMiddleware';
...

export const stopPolling = () => stopInterval(MY_API_REQUEST_SPECIAL_KEY);
```

Then it will be available in your component:
```js
// MyComponent/MyComponent.js
handlePolling = () => {
  /**use the same key that was used to create the API request with polling.*/
  this.props.stopPolling(MY_API_REQUEST_SPECIAL_KEY) 
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
  /**use the same key that was used to create the API request with polling.*/
  stopInterval(MY_API_REQUEST_SPECIAL_KEY) 
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
  /**use the same key that was used to create the API request with polling.*/
  dispatch(stopInterval(MY_API_REQUEST_SPECIAL_KEY))
}
```