# Adding components

## Where to put them

Components are stored in `webpack/assets/javascripts/react_app/components/`. Each component should be placed in its own subfolder that respects the following structure:

```
─ components/<COMPONENT_NAME>/
   ├─ <COMPONENT_NAME>.js            ┈ pure react component
   ├─ <COMPONENT_NAME>.scss          ┈ styles if needed
   ├─ <COMPONENT_NAME>Actions.js     ┈ redux actions
   ├─ <COMPONENT_NAME>Reducer.js     ┈ redux reducer
   ├─ <COMPONENT_NAME>Selectors.js   ┈ reselect selectors
   ├─ <COMPONENT_NAME>Constants.js   ┈ constants such as action types
   ├─ <COMPONENT_NAME>.fixtures.js   ┈ constants for testing, initial state, etc.
   ├─ <COMPONENT_NAME>.stories.js    ┈ storybook pages for the component
   ├─ components/                    ┈ folder for nested components if needed
   ├─ __tests__/                     ┈ folder for tests
   ╰─ index.js                       ┈ redux connected file
```

## Storybook

[Storybook](https://storybook.js.org/) is an isolated environment for developing and demonstrating components. It serves as a nice documentation of a component usage.

Each component that is supposed to be used at multiple places in the application should add its stories into the "Components" menu. The stories should be placed in a file `<COMPONENT_NAME>.stories.js` in the component's main folder. The storybook in Foreman loads all `*.story.js` files from `webpack/` automatically.

An example of such stories is [BreadcrumbBar.stories.js](https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/components/BreadcrumbBar/BreadcrumbBar.stories.js).

On top of the basic storybook Foreman uses [knobs addon](https://github.com/storybooks/storybook/tree/master/addons/knobs#available-knobs) that enables switching values of component's properties and [actions addon](https://github.com/storybooks/storybook/tree/master/addons/actions#getting-started) for logging of callbacks. It's worth checking their docs as the usage is simple and they can provide nice user experience.


### Running storybook

Starting the storybook server is as easy as `npm run storybook`. By default the server is started on `localhost:6006`.

If some extra configuration is needed, you can start the storybook's executable directly. For example:
```bash
# Starting storybook on https with Katello certs
./node_modules/.bin/start-storybook \
  --port 6006 \
  --host $(hostname) \
  --https \
  --ssl-key /etc/pki/katello/private/katello-apache.key \
  --ssl-cert /etc/pki/katello/certs/katello-apache.crt \
  --ssl-ca /etc/pki/katello/certs/katello-default-ca.crt
```

## Testing

Tests must be placed in `__tests__` subfolder of the main component's folder. Tests for the component, reducer and actions must have their own files named `<TESTED_PIECE>.test.js`:

```
╰─ __tests__
    ├─ <COMPONENT_NAME>Actions.test.js
    ├─ <COMPONENT_NAME>Reducer.test.js
    ├─ <COMPONENT_NAME>.test.js
    ├─ integration.test.js
    ╰─ __snapshots__
        ├── # All snapshot files (created automaically, updated with `npm test -- -u`)
```

### Testing components

In most cases (when the component doesn't provide any user interaction callbacks) it's enough to test how the component is rendered with various supported properties. Foreman uses [enzyme](https://github.com/airbnb/enzyme) for that.

There are 3 ways how a component can be rendered in enzyme:
  - **shallow** - render subcomponents as names, **preferred alternative**, more details in [docs](https://github.com/airbnb/enzyme/blob/master/docs/api/shallow.md)
  - **mount** - full rendering API, useful when you need to interact with dom, more details in [docs](https://github.com/airbnb/enzyme/blob/master/docs/api/mount.md)
  - **render** - static rendering, more details in [docs](https://github.com/airbnb/enzyme/blob/master/docs/api/render.md)

### Running the tests

All tests can be executed with `npm test`.

If you want to run only a single test use `jest` directly: `./node_modules/.bin/jest <path/to/some.test.js>`
This is useful especially for debugging because it doesn't hide console output.

Linter (code style checking) can be executed with `npm run lint`. You can run it with parameter `--fix` to let it automatically fix the discovered issues.


## Making it available from erb

If you want your component to be available for mounting into erb templates, you have to add them to [the component registry](https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/components/componentRegistry.js#L60-L71).

Then it will be possible to mount it with `mount_react_component` helper:
```ruby
mount_react_component(component_name, html_node_selector, json_data)
```

**Example:**
```erb
<%= mount_react_component('PowerStatus', '#power', {:id => host.id, :url => power_host_path(host.id)}.to_json) %>
```

## Before you start writing a new component

It's worth checking patternfly-react [Github repository](https://github.com/patternfly/patternfly-react) and [storybook](https://rawgit.com/patternfly/patternfly-react/gh-pages/index.html) to make sure such component doesn't exist yet. Also consider if your component is universal enough to be used in other projects. In such case it might make sense to add it to patternfly-react instead.

Another place to look in is [move_to_foreman](https://github.com/Katello/katello/tree/master/webpack/move_to_foreman) folder in Katello. It already contains some components and code that is waiting to be moved to the core.
