import React from 'react';
import { configure, storiesOf } from '@storybook/react';
import Markdown from './components/Markdown';

import gettingStarted from './docs/gettingStarted.md';
import addingNewComponent from './docs/addingNewComponent.md';
import addingDependencies from './docs/addingDependencies.md';
import internationalization from './docs/internationalization.md';
import plugins from './docs/plugins.md';

require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');
require('../../app/assets/stylesheets/base.scss');

const req = require.context('../assets/javascripts/react_app', true, /.stories.js$/);

const loadStories = () => req.keys().forEach(filename => req(filename));

storiesOf('Introduction', module)
  .add('Getting started', () => <Markdown source={gettingStarted} />)
  .add('Adding new component', () => <Markdown source={addingNewComponent} />)
  .add('Adding dependencies', () => <Markdown source={addingDependencies} />)
  .add('Internationalization', () => <Markdown source={internationalization} />)
  .add('Plugins', () => <Markdown source={plugins} />);

configure(loadStories, module);
