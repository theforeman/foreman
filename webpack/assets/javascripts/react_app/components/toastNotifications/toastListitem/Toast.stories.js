import React from 'react';
import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';
import Toast from './index';

function getDismiss() {
  return action('dismiss alert');
}

storiesOf('Notifications', module)
  .add('Error', () => (
    <Toast message="Please don't do that again" type="error" dismiss={getDismiss()} />
  ))
  .add('Oops - no close', () => (
    <Toast message="Please don't do that again" type="error" dismissable={false} sticky={true} />
  ))
  .add('Success with link', () => (
    <Toast
      message="Payment received"
      type="success"
      link={{ title: 'click for details', href: 'google.com' }}
      dismiss={getDismiss()}
    />
  ))
  .add('Warning', () => (
    <Toast message="I'm not sure you should do that" type="warning" dismiss={getDismiss()} />
  ))
  .add('Short life', () => (
    <Toast message="I'm about to expire" type="warning" dismiss={getDismiss()} />
  ))
  .add('Sticky', () => (
    <Toast
      message="I'm Going to stick around"
      type="warning"
      sticky={true}
      dismiss={getDismiss()}
    />
  ));
