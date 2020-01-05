import 'core-js/shim';
import 'regenerator-runtime/runtime';
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
import APIMiddleware from './docs/APIMiddleware.md';
import APIMiddlewareUsage from './docs/APIMiddlewareUsage.md';
import intervalMiddleware from './docs/intervalMiddleware.md';
import plugins from './docs/plugins.md';
import SlotAndFill from './docs/SlotAndFill.md';
import LegacyJs from './docs/LegacyJs.md';
import ForemanFrontendDiagram from './docs/foreman-frontend-infra.png';
import creatingForm from './docs/creatingForm.md';

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
      <img src={ForemanFrontendDiagram} alt="Foreman Frontend Infrastructure" />
      <Markdown source={LegacyJs} />
    </Story>
  ))
  .add('Interval Middleware', () => (
    <Story>
      <Markdown source={intervalMiddleware} />
    </Story>
  ))
  .add('Creating a form', () => (
    <Story>
      <Markdown source={creatingForm} />
    </Story>
  ));

storiesOf('Introduction/API middleware', module)
  .add('API Middleware', () => (
    <Story>
      <Markdown source={APIMiddleware} />
    </Story>
  ))
  .add('Simple Usage', () => (
    <Story>
      <Markdown source={APIMiddlewareUsage} />
    </Story>
  ));

configure(loadStories, module);
