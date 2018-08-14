import React from 'react';
import { configure, storiesOf } from '@storybook/react';
import Markdown from './components/Markdown';
import Story from './components/Story';

import './index.scss';
import gettingStarted from './docs/gettingStarted.md';
import addingNewComponent from './docs/addingNewComponent.md';
import hoc from './docs/hoc.md';
import addingDependencies from './docs/addingDependencies.md';
import internationalization from './docs/internationalization.md';
import plugins from './docs/plugins.md';
import SlotAndFill from './docs/SlotAndFill.md';
import LegacyJs from './docs/LegacyJs.md';
import tours from './docs/tours.md';

require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');

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
  .add('HOCs', () => (
    <Story>
      <Markdown source={hoc} />
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
  ))
  .add('Slot&Fill', () => (
    <Story>
      <Markdown source={SlotAndFill} />
    </Story>
  ))
  .add('Legacy Javascript', () => (
    <Story>
      <Markdown source={LegacyJs} />
    </Story>
  ))
  .add('Tours', () => (
    <Story>
      <Markdown source={tours} />
    </Story>
  ));

configure(loadStories, module);
