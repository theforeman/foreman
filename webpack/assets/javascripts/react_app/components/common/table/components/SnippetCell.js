import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';

const SnippetCell = ({ condition }) =>
  condition ? (
    <span className="fa fa-check"/>
  ) : null;

SnippetCell.propTypes = {
  condition: PropTypes.bool,
};

SnippetCell.defaultProps = {
  condition: false,
};

export default SnippetCell;
