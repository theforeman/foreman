import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';
import DefaultEmptyState from '../../../components/common/EmptyState';
import './emptypage.scss';

const EmptyPage = ({ message: { type, text } }) => {
  const headerTextMap = {
    empty: __('No Results'),
    error: __('Error'),
    loading: __('Loading'),
  };
  const headerText = headerTextMap[type];
  return (
    <DefaultEmptyState
      icon={type === 'error' ? 'error-circle-o' : 'add-circle-o'}
      header={headerText}
      description={text}
    />
  );
};

EmptyPage.propTypes = {
  message: PropTypes.shape({
    type: PropTypes.oneOf(['empty', 'error', 'loading']),
    text: PropTypes.string,
  }),
};

EmptyPage.defaultProps = {
  message: {
    type: 'empty',
    text: 'No Results',
  },
};

export default EmptyPage;
