require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');
require('../../app/assets/stylesheets/base.scss');
import { configure } from '@storybook/react';

const req = require.context('../assets/javascripts/react_app', true, /.stories.js$/);

function loadStories() {
  req.keys().forEach(filename => req(filename));
}

configure(loadStories, module);
