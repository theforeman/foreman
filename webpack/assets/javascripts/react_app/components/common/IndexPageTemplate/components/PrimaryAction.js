import React from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';

const PrimaryAction = ({ label, path }) =>
  label ? (
    <Button isInline component="a" href={path}>
      {label}
    </Button>
  ) : null;

PrimaryAction.propTypes = {
  label: PropTypes.string,
  path: PropTypes.string,
};

PrimaryAction.defaultProps = {
  label: '',
  path: '',
};

export default PrimaryAction;
