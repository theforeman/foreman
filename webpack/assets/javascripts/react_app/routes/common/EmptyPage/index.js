import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';
import DefaultEmptyState from '../../../components/common/EmptyState';
import './emptypage.scss';

const EmptyPage = ({ message: { type, text } }) => (
  <DefaultEmptyState
    icon={type === 'error' ? 'error-circle-o' : 'add-circle-o'}
    header={type === 'error' ? __('Error') : __('No Results')}
    description={text}
  />
);

EmptyPage.propTypes = {
  message: PropTypes.shape({
    type: PropTypes.oneOf(['empty', 'error']),
    text: PropTypes.string,
  }),
};

EmptyPage.defaultProps = {
  message: PropTypes.shape({
    type: 'empty',
    text: 'No Results',
  }),
};

export default EmptyPage;
