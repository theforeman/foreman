# API Middleware

Instead of each component handling API calls in the same way we have the API Middleware that will handle it instead.

the API Actions can be imported from 'webpack/assets/javascripts/react_app/redux/API/index.js'
or 'foremanReact/redux/API/index.js' for plugins

currently the `get` action is available, and soon we will support all of the API operations.

## How to use it in your action

```js
import { get } from '../../redux/API';

const someAction = url =>
  get({
    key: MY_SPECIAL_KEY, // this will be used later to identify your API call, so keep it unique.
    url,
    params: {}, // some params you will want to pass to the API request.
    headers: {}, // some headers you will want to pass to the API request.
  })
```

or

```js
dispatch(
  get({
    key: MY_SPECIAL_KEY, // this will be used later to identify your API call, so keep it unique.
    url,
    params: {}, // some params you will want to pass to the API request.
    headers: {}, // some headers you will want to pass to the API request.
  }));
```

Then there will be called 2 actions: **MY_SPECIAL_KEY_REQUEST** and **MY_SPECIAL_KEY_SUCCESS/ MY_SPECIAL_KEY_FAILURE**:
**MY_SPECIAL_KEY_REQUEST** will have the payload only
**MY_SPECIAL_KEY_SUCCESS** will have the payload and the return data from the API call.
**MY_SPECIAL_KEY_FAILURE** will have the payload and the return error from the API call.

In the **payload** field you should send any headers and params for the GET request, and any other data you want for the action.

The actions types can be changed with the optional **actionTypes** parameter:

```js
dispatch(
  get({
    key: MY_SPECIAL_KEY, // this will be used later to identify your API call, so keep it unique.
    url,
    params: {} // some params you will want to pass to the API request.
    headers: {}, // some headers you will want to pass to the API request.
    actionTypes: {
      REQUEST: 'CUSTOM_REQUEST',
      SUCCESS: 'CUSTOM_SUCCESS', 
      FAILURE: 'CUSTOM_FAILURE',
    },
  })
);
```
