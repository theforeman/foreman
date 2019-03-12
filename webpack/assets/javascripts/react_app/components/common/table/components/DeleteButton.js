import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { translate as __ } from '../../../../common/I18n';

// TODO(bshuster): Move the confirmation to DialogModal that uses API to
//                 delete the item.
const DeleteButton = ({ active, id, name, controller }) =>
  active ? (
    <Button
      bsStyle="default"
      data-method="delete"
      data-confirm={`${__('Delete')} ${name}?`}
      href={`${controller}/${id}-${name}`}
    >
      {__('Delete')}
    </Button>
  ) : null;

DeleteButton.propTypes = {
  active: PropTypes.bool,
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  controller: PropTypes.string.isRequired,
};

DeleteButton.defaultProps = {
  active: false,
};

export default DeleteButton;
