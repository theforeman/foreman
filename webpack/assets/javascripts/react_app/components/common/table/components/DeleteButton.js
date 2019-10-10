import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { translate as __ } from '../../../../common/I18n';

const DeleteButton = ({ active, onClick }) =>
  active ? (
    <Button bsStyle="default" onClick={onClick}>
      {__('Delete')}
    </Button>
  ) : null;

DeleteButton.propTypes = {
  active: PropTypes.bool,
  onClick: PropTypes.func.isRequired,
};

DeleteButton.defaultProps = {
  active: false,
};

export default DeleteButton;
