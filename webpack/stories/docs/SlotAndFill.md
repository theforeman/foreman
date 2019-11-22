# Slot And Fill

Slot & Fill allows plugins to extend foreman core functionality in the UI

## Current Slots List
| Name                | Id               | Path  |
| ------------------- |:----------------:| -----:|
| **About-footer**    | aboutFooterSlot  | *views/about/index.html.erb*
| **Host params**     | HostgroupParams  | *views/hostgroups/_form.html.erb*
| **Hostgroup params**| HostParams       | *views/hosts/_form.html.erb*

## Components

### Slot
`<Slot>` is an opinionated extension point which responsible of rendering its fills
a Slot can support multiple fills, rendering by weight order by the `multi` prop
if there is no such prop, it will render the max weighted fill.

### Fill
a fill is the filled object of a slot

#### Component fill
a fill that contains a child  component, which rendered by a dedicated slot

*core*
```js
<Slot id='slot-id'>
 a default child // can be empty
</Slot>
```

*plugin A*
```js
<Fill slotId='slot-id' id='some-id' weight={100}> 
  <div> some text </ div>
</ Fill>
```

*plugin B*
```js
<Fill slotId='slot-id' id='some-id' weight={200}> 
  <div> some text </ div>
</ Fill>
```

Plugin B has a fill with a higher weight, therefore it will be rendered in a dedicated slot.

#### Component fill - remdering multiple fills
If a slot has a `multi` prop, and it has multiple fills, it will render these fills by weight order

*core*
```js
<Slot multi id='slot-id' />
```

*plugin A*
```js
<Fill slotId='slot-id' id='some-id' weight={100}> 
  <div> some text </ div>
</ Fill>
```

*plugin B*
```js
<Fill slotId='slot-id' id='some-id' weight={200}> 
  <div> some text </ div>
</ Fill>
```

Plugin B's fill will be render first

#### Props fill
a fill that contains an `overrideProps` object
those props are given to the slot's children


*core*
```js
const TextWrapper = ({ text }) => <div>{text}</div>; 

<Slot id='slot-id'>
  <TextWrapper text='some default text' />
</Slot>
```

*plugin A*
```js
<Fill slotId='slot-id' id='some-id' weight={200} overrideProps={{ text: '[Plugin A] this text given by a prop' }} /> 
```


*plugin B*
```js
<Fill slotId='slot-id' id='some-id' weight={100} overrideProps={{ text: '[Plugin B] this text given by a prop' }} /> 
```
In this case, the slot doesn't have `multi` prop, therefore it will take the max weight which is Plugin A's fill.

#### Global fill
This fill is available on each and every core page
A plugin should use global fills when it doesn't have access to that area (i.e adding a component in the about page)
If a plugin wants to extend foreman's layout, or whether it has a partial in a core page via facets, a regular fill is enough.

create a `fills_index.js` file under webpack directory:
```js
import React from 'react';
import SomeComponent from './components/SomeComponent';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';

// if some of the components are connected to redux, registering a reducer is required
registerReducer('[plugin]-extends', extendReducer); 


addGlobalFill('slotId', 'fillId', <SomeComponent key="some-key" />, 300);
// instead of a component, you can also override props 
addGlobalFill('slotId', 'fillId', { someProp: 'this is an override prop' }, 300);
```

Register `fills` global file in `plugn.rb` file:

```ruby
Foreman::Plugin.register :<plugin> do
# content
  register_global_file 'fills'
end
```

Finally, add a slot in foreman core:

```ruby
  <%= slot('slotId', true) %>
```
