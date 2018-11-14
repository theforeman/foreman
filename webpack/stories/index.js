import React from 'react';
import { configure, storiesOf } from '@storybook/react';
import Markdown from './components/Markdown';
import Story from './components/Story';

import './index.scss';
import gettingStarted from './docs/gettingStarted.md';
import addingNewComponent from './docs/addingNewComponent.md';
import addingDependencies from './docs/addingDependencies.md';
import internationalization from './docs/internationalization.md';
import plugins from './docs/plugins.md';

require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');
require('../../app/assets/stylesheets/base.scss');

require('patternfly/dist/js/patternfly');

require('./index.scss');

const req = require.context(
  '../assets/javascripts/react_app',
  true,
  /.stories.js$/
);

const loadStories = () => req.keys().forEach(filename => req(filename));

storiesOf('Introduction', module)
  .add('Getting started', () => (
    <Story>
      <Markdown source={gettingStarted} />
    </Story>
  ))
  .add('Adding new component', () => (
    <Story>
      <Markdown source={addingNewComponent} />
    </Story>
  ))
  .add('Adding dependencies', () => (
    <Story>
      <Markdown source={addingDependencies} />
    </Story>
  ))
  .add('Internationalization', () => (
    <Story>
      <Markdown source={internationalization} />
    </Story>
  ))
  .add('Plugins', () => (
    <Story>
      <Markdown source={plugins} />
    </Story>
  ));

configure(loadStories, module);
