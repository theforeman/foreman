import React from 'react';
import { useDispatch } from 'react-redux';
import { Button } from '@patternfly/react-core';
import { action } from '@storybook/addon-actions';
import { boolean, text, object } from '@storybook/addon-knobs';
import storeDecorator from '../../../../../stories/storeDecorator';
import Story from '../../../../../stories/components/Story';
import ConfirmModal, { openConfirmModal } from '.';

export default {
  title: 'Components/Confirm modal',
  decorators: [storeDecorator],
};

export const ConfirmBasicUsage = () =>
  React.createElement(() => {
    const dispatch = useDispatch();
    const isWarning = boolean('isWarning', false);
    const title = text('title', 'Confirm');
    const message = text('message', 'Are you sure?');
    const confirmButtonText = text('confirmButtonText', null);
    const handleConfirmClick = () => {
      dispatch(
        openConfirmModal({
          title,
          message,
          isWarning,
          confirmButtonText,
          onConfirm: action('Confirmed!'),
          onCancel: action('Canceled!'),
        })
      )
    };
    
    return (
      <Story>
        <Button onClick={handleConfirmClick}>
          Trigger confirm !
        </Button>
        {/* The confirm modal is already declared on the app's root */}
        <ConfirmModal /> 
      </Story>
    );
  });

  ConfirmBasicUsage.story = {
  name: 'Basic usage',
};
