import { configure } from '@storybook/react';

function loadStories() {
  require('../webpack/stories');
}

configure(loadStories, module);
