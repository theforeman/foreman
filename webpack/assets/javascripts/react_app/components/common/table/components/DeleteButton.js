import React from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';
import { translate as __ } from '../../../../common/I18n';

const DeleteButton = ({ active, onClick }) =>
  active ? (
    <Button ouiaId="table-delete-button" variant="secondary" onClick={onClick}>
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
