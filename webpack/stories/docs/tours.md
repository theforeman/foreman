# Tour

## React Components
In order to create a tour of your react component, please add a `<YourComponent>Tour.js` file in the component's library

### Example
```js
import withTour from '../../common/Tour';
import <YourComponent> from './<your component>';

const steps = [
  {
    selector: '[data-tut="selector_1"]',
    content: __('Welcome the new feature !'),
  },
  {
    selector: '[data-tut="selector_2"]',
    content: __('This is step 2'),
  },
  {
    selector: '[data-tut="selector_3"]',
    content: __('This is another step'),
  },
];

export default withTour(YourComponent, steps, '<unique ID>');
```

Each selector is a one step of your tour, add a data attribute named `data-tut` on each element which is displayed as a step.
The `WithTour` HOC adds a special callback named `runTour` which adding this tour to a runnig queue.
You can call `runTour` on your wrapped component everywhere, for example under `componentDidMount` for instant running, or under a click event.


## Rails Views
Tour can run over rails view content as well!
Please note that the tour will run instantly on page load.

### Example
```ruby
<%= run_tour('<unique ID>', [
  {
    selector: '[data-tut="selector_1"]',
    content: _('It works with ERB as well!'),
  }]) %>
  ```