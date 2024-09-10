import React from 'react';
import { Icon } from 'patternfly-react';
import {
  EmptyState,
  EmptyStateVariant,
  EmptyStateBody,
  EmptyStateActions,
  EmptyStateHeader,
  EmptyStateFooter,
} from '@patternfly/react-core';
import { emptyStatePatternPropTypes } from './EmptyStatePropTypes';
import { translate as __ } from '../../../common/I18n';
import './EmptyState.scss';

const EmptyStatePattern = props => {
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
      <EmptyStateHeader titleText={<>{header}</>} headingLevel="h5" />
      <EmptyStateBody>
        <div className="empty-state-description">{description}</div>
        <DocumentationBlock />
      </EmptyStateBody>
      <EmptyStateFooter>
        {action}
        <EmptyStateActions>{secondaryActions}</EmptyStateActions>
      </EmptyStateFooter>
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
