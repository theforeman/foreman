import React from 'react';
import { storiesOf } from '@storybook/react';
import PermissionDenied from '.';
import Story from '../../../../../stories/components/Story';

storiesOf('Components/PermissionDenied', module)
  .add('With default text', () => (
    <Story>
      <PermissionDenied
        missingPermissions={['view_organizations', 'import_manifest']}
      />
    </Story>
  ))
  .add('With custom text', () => (
    <Story>
      <PermissionDenied
        backHref="/home/dashboard"
        texts={{
          notAuthorizedMsg: "Hey! You can't do that.",
          pleaseRequestMsg:
            'Please ask an admin to get you the following permissions:',
          permissionDeniedMsg: 'Access denied',
        }}
        missingPermissions={['view_organizations', 'import_manifest']}
      />
    </Story>
  ));
