import React from 'react';
import PropTypes from 'prop-types';
import DefaultEmptyState from '../../../components/common/EmptyState';

const AuditsPageEmptyState = ({ message }) => (
  <DefaultEmptyState
    icon={message.type === 'error' ? 'error-circle-o' : 'add-circle-o'}
    header={message.type === 'error' ? __('Error') : __('No Audits Found')}
    description={message.text}
  />
);

AuditsPageEmptyState.propTypes = {
  message: PropTypes.shape({
    type: PropTypes.string,
    text: PropTypes.string,
  }).isRequired,
};

export default AuditsPageEmptyState;
