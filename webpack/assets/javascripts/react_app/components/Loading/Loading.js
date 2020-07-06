import React from 'react';
import PropTypes from 'prop-types';
import {
  Bullseye,
  Title,
  EmptyState,
  EmptyStateIcon,
  Spinner,
} from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';

// Centered patternfly 4 loading icon
const Loading = ({ textSize, iconSize, showText }) => {
  const LoadingSpinner = () => (
    <Spinner size={iconSize} aria-label="loading icon" />
  );
  return (
    <Bullseye>
      <EmptyState>
        <EmptyStateIcon variant="container" component={LoadingSpinner} />
        {showText && (
          <Title size={textSize} headingLevel="h4">
            {__('Loading')}
          </Title>
        )}
      </EmptyState>
    </Bullseye>
  );
};

Loading.propTypes = {
  textSize: PropTypes.string,
  iconSize: PropTypes.string,
  showText: PropTypes.bool,
};

Loading.defaultProps = {
  textSize: 'lg',
  iconSize: 'xl',
  showText: true,
};

export default Loading;
