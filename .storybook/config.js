import { configure } from '@kadira/storybook';

function loadStories() {
  require('../webpack/react_app/storybook');
}

configure(loadStories, module);
