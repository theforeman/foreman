import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';

const LockedCell = ({ condition }) =>
  condition ? (
    <span className="glyphicon glyphicon-lock" title={`${__('This template is locked for editing.')}`}/>
  ) : null;

LockedCell.propTypes = {
  condition: PropTypes.bool,
};

LockedCell.defaultProps = {
  condition: false,
};

export default LockedCell;
