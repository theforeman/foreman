# API Middleware with polling

current generic API action looks like this:

```js
const some_API_action = payload => ({
  type: API_OPERATIONS.GET,
  key: MY_API_REQUEST_SPECIAL_KEY,
  payload,
});
```

To use polling, we will need to add the "polling" key:

```js
const some_API_action = payload => ({
  type: API_OPERATIONS.GET,
  key: MY_API_REQUEST_SPECIAL_KEY,
  polling: 3000, /** value in ms, or true which will use the default values. */  
  payload,
});
```

To stop the polling, we will need to use the "stopPolling" Action from APIActions:
```js
// MyComponent/index.js
import { APIActions } from "../../redux/API";
// import { APIActions } from "foremanReact/redux/API"; in plugins
...
const mapDispatchToProps = dispatch => bindActionCreators( { ...actions, ...APIActions }, dispatch)
```

Then it will be available in your component:
```js
// MyComponent/MyComponent.js
handlePolling = () => {
  /**use the same key that was used to create the API request with polling.*/
  this.props.stopPolling(MY_API_REQUEST_SPECIAL_KEY) 
}
```

Instead of adding the APIActions to mapDispatchToProps,
you could also use the redux-hook to fire the action:
```js
// MyComponent/MyComponent.js
import { useDispatch } from 'react-redux'
import { stopPolling } from "../../redux/API/APIActions";
// import { APIActions } from "foremanReact/redux/API/APIActions"; in plugins
...
handlePolling = () => {
  const dispatch = useDispatch()
  /**use the same key that was used to create the API request with polling.*/
  dispatch(stopPolling(MY_API_REQUEST_SPECIAL_KEY))
}
```