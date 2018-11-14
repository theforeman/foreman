# Plugins

## Using components from core

There are three ways how components provided by Foreman core can be re-used:

### Mounting components into erb

No special setup is required and you can re-use React components that are available in `componentRegistry` even when you plugin doesn't use webpack.
Components can be mounted into erb using `mount_react_component` helper:

```ruby
mount_react_component(component_name, html_node_selector, json_data)
```

**Example:**
```erb
<%= mount_react_component('PowerStatus', '#power', {:id => host.id, :url => power_host_path(host.id)}.to_json) %>
```

The list of available compoennts is [here](https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/components/componentRegistry.js#L60).


### Re-using core code in webpack

If your plugin uses webpack, you can import and the core functionality from `foremanReact`.

**Example:**
 ```js
// import helpers from foremanReact:
import { noop } from 'foremanReact/common/helpers';

// import components from foremanReact:
import { MessageBox } from 'foremanReact/components/common/MessageBox';
```

Please note that using functionality from core may cause troubles in jest tests where `foremanReact` isn't available because it isn't a real npm package, see [the webpack configuration](https://github.com/theforeman/foreman/blob/develop/config/webpack.config.js#L70-L76) for details.

Until this is fixed in Foreman core the workaround is using [mocks](https://github.com/Katello/katello/tree/master/webpack/__mocks__) in your plugin's tests.


### Using components outside of webpack

The component registry is available in `Window.tfm.componentRegistry`. That gives you access to the components even from js code that isn't processed by webpack.

```js
const MyComponent = Window.tfm.componentRegistry.getComponent(componentName).type;
```

Most of the components require to be wrapped with a [Higher-Order Component](https://reactjs.org/docs/higher-order-components.html) that provides some context like Redux store or Intl. `componentRegistry` publishes a wrapper factory that can create a wrapper function with HOCs according to your needs.

```js
const i18nWrapper = componentRegistry.wrapperFactory().with('i18n').wrapper;
const MyComponentWithIntl = i18nWrapper(MyComponent);
```


# Using webpack in plugin

There are 3 conditions that a plugin has to fulfill to share the webpack infrastructure from Foreman core:

- folder `./webpack/` containing all the webpack processed code
- `package.json` in with dependencies
- defined main entry point in `package.json` or just have `./webpack/index.js`

The webpack config is shared with core so there's no need for custom configuration.

Once all the above is set up then the script `npm run install` executed from root of the core's git checkout installs dependencies for plugins too.
Also `npm run lint` behaves similarly.


### Troubleshooting

You can make sure webpack knows about your plugin by executing script `plugin_webpack_directories.rb` that prints json-formatted info about all recognized plugins.

```bash
> ./script/plugin_webpack_directories.rb | json_reformat
{
    "entries": {
        "katello": "/home/vagrant/foreman/katello/webpack/index.js"
    },
    "paths": [
        "/home/vagrant/foreman/katello/webpack"
    ],
    "plugins": {
        "katello": {
            "root": "/home/vagrant/foreman/katello",
            "entry": "/home/vagrant/foreman/katello/webpack/index.js"
        }
    }
}
```
