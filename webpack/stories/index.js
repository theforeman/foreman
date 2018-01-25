import { configure } from '@storybook/react';

import '../assets/javascripts/bundle';
import '../../app/assets/javascripts/application';

const req = require.context('../assets/javascripts/react_app', true, /.stories.js$/);

function loadStories() {
  req.keys().forEach(filename => req(filename));
}

configure(loadStories, module);
