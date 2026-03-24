import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { translate as __ } from '../../../../common/I18n';
import { deprecate } from '../../../../common/DeprecationService';

const DeleteButton = ({ active, onClick }) => {
  useEffect(() => {
    deprecate(
      'table/components/DeleteButton',
      'Button from @patternfly/react-core',
      '3.21'
    );
  }, []);

  return active ? (
    <Button bsStyle="default" onClick={onClick}>
      {__('Delete')}
    </Button>
  ) : null;
};

DeleteButton.propTypes = {
  active: PropTypes.bool,
  onClick: PropTypes.func.isRequired,
};

DeleteButton.defaultProps = {
  active: false,
};

export default DeleteButton;
