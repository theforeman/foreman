import React from 'react';
import { storiesOf } from '@storybook/react';
import { text, withKnobs } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';
import DeleteConfirmationDialog from './DeleteConfirmationDialog';

storiesOf('Components/Delete Message Dialog', module)
  .addDecorator(withKnobs)
  .add('Delete Confirmation Dialog', () => {
    const hostname = text('hostname', 'foreman.local.1');
    return (
      <DeleteConfirmationDialog
        show
        onDelete={action('delete item')}
        onHide={action('close window')}
        id={1}
        controller="hosts"
        name={hostname}
      />
    );
  });
