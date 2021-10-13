import React from 'react';
import { Icon } from 'patternfly-react';
import {
  Title,
  EmptyState,
  EmptyStateVariant,
  EmptyStateBody,
  EmptyStateSecondaryActions,
} from '@patternfly/react-core';
import { emptyStatePatternPropTypes } from './EmptyStatePropTypes';
import { translate as __ } from '../../../common/I18n';
import './EmptyState.scss';

const EmptyStatePattern = (props) => {
  const {
    documentation,
    action,
    secondaryActions,
    iconType,
    icon,
    header,
    description,
  } = props;

  const DocumentationBlock = () => {
    if (!documentation) {
      return null;
    }
    // The documentation prop can also be a customized node
    if (React.isValidElement(documentation)) {
      return documentation;
    }
    const {
      label = __('For more information please see '), // eslint-disable-line react/prop-types
      buttonLabel = __('documentation'), // eslint-disable-line react/prop-types
      url = '#', // eslint-disable-line react/prop-types
    } = documentation;
    return (
      <span>
        {label}
        <a href={url} target="_blank" rel="external noreferrer noopener">
          {buttonLabel}
        </a>
      </span>
    );
  };

  const EmptyStateIcon = () =>
    React.isValidElement(icon) ? (
      icon
    ) : (
      <Icon name={icon} type={iconType} size="2x" />
    );

  return (
    <EmptyState variant={EmptyStateVariant.xl}>
      <span className="empty-state-icon">
        <EmptyStateIcon />
      </span>
      <Title headingLevel="h5" size="4xl">
        {header}
      </Title>
      <EmptyStateBody>
        <div className="empty-state-description">{description}</div>
        <DocumentationBlock />
      </EmptyStateBody>
      {action}
      <EmptyStateSecondaryActions>
        {secondaryActions}
      </EmptyStateSecondaryActions>
    </EmptyState>
  );
};

EmptyStatePattern.propTypes = emptyStatePatternPropTypes;

EmptyStatePattern.defaultProps = {
  icon: 'add-circle-o',
  secondaryActions: [],
  documentation: null,
  action: null,
  iconType: 'pf',
};

export default EmptyStatePattern;
