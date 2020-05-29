import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';
import { ActionButtons } from '../../ActionButtons/ActionButtons';

export const TemplateActionButton = ({
  id,
  name,
  vendor,
  availableActions: { generatable, lockable, unlockable },
  templateActions,
  permissions: { canDelete },
}) => {
  const buttons = [];
  if (generatable) {
    buttons.push({
      title: __('Generate'),
      action: {
        'data-method': 'get',
        'href': templateActions.generate(id, name),
      },
    });
  }
  buttons.push({
    title: __('Clone'),
    action: {
      'data-method': 'get',
      'href': templateActions.clone(id, name),
    },
  });
  buttons.push({
    title: __('Export'),
    action: {
      'data-method': 'get',
      'href': templateActions.export(id, name),
    },
  });
  if (lockable) {
    buttons.push({
      title: __('Lock'),
      action: {
        'data-method': 'get',
        'href': templateActions.lock(id, name),
      },
    });
  }
  if (unlockable) {
    let confirm = [
      __('You are about to unlock a locked template.'),
      __('This is for every location and organization that uses it.')
    ];
    if (vendor) {
      confirm.push(__(`It is not recommended to unlock this template, as it is provided by ${vendor} and may be overwritten. Please consider cloning it instead.`));
    }
    confirm.push(__('Continue?'));
    buttons.push({
      title: __('Unlock'),
      action: {
        'data-method': 'get',
        'href': templateActions.unlock(id, name),
        'data-confirm': `${confirm.join(' ')}`,
        'bsStyle': 'danger', // TODO: doesn't work :(
      },
    });
  }
  if (canDelete && lockable) {
    buttons.push({
      title: __('Delete'),
      action: {
        'data-method': 'delete',
        'href': templateActions.delete(id, name),
        'data-confirm': `${__('Delete')} ${name}?`,
      },
    });
  }

  return (
    <span>
      <ActionButtons buttons={buttons} />
    </span>
  );
};

TemplateActionButton.propTypes = {
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  vendor: PropTypes.bool.isRequired,
  availableActions: PropTypes.shape({
    generatable: PropTypes.bool,
    lockable: PropTypes.bool,
    unlockable: PropTypes.bool,
  }).isRequired,
  templateActions: PropTypes.shape({
    generate: PropTypes.func,
    lock: PropTypes.func,
    unlock: PropTypes.func,
  }).isRequired,
  permissions: PropTypes.shape({
    canDelete: PropTypes.bool,
  }).isRequired,
};
