# API Middleware

Instead of each component handling API calls in the same way we have the API Middleware that will handle it instead.
Current use as an action:

API_OPERATIONS is defined in 'webpack/assets/javascripts/react_app/redux/API.js'
or 'foremanReact/redux/API' for plugins
```js
import { API_OPERATIONS } from ...;
const someAction = url => ({
  type: API_OPERATIONS.GET,
  key: COMPONENT_NAME,
  url,
  
});
```

or

```js
dispatch({
  type: API_OPERATIONS.GET,
  key: COMPONENT_NAME,
  url,
  payload: data,
});
```

Then there will be called 2 actions: **COMPONENT_NAME_REQUEST** and **COMPONENT_NAME_SUCCESS/ COMPONENT_NAME_FAILURE**:
**COMPONENT_NAME_REQUEST** will have the payload only
**COMPONENT_NAME_SUCCESS** will have the payload and the return data from the API call.
**COMPONENT_NAME_FAILURE** will have the payload and the return error from the API call.

In the **payload** field you should send any headers and params for the GET request, and any other data you want for the action.

The actions types can be changed with the optional **actionTypes** parameter:

```js
dispatch({
  type: API_OPERATIONS.GET,
  key: COMPONENT_NAME,
  url,
  actionTypes: {
    REQUEST: 'CUSTOM_REQUEST',
    SUCCESS: 'CUSTOM_SUCCESS', 
    FAILURE: 'CUSTOM_FAILURE',
  }
});
```
**Option functions**

`errorFormat`: format function for the error in the payload
`successFormat`: format function for the data in the payload
`onSuccess`: function to run on success, recieves the response
`onFailure`: function to run on failure, recieves the error