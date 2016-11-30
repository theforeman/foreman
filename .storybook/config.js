import { configure } from '@kadira/storybook';

function loadStories() {
  require('../webpack/stories');
}

configure(loadStories, module);
