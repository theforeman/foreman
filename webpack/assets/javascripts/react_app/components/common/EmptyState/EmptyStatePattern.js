import React from 'react';
import {
  Title,
  EmptyState,
  EmptyStateVariant,
  EmptyStateBody,
  EmptyStateSecondaryActions,
  EmptyStateIcon,
} from '@patternfly/react-core';
import { PlusCircleIcon } from '@patternfly/react-icons';
import { emptyStatePatternPropTypes } from './EmptyStatePropTypes';
import { translate as __ } from '../../../common/I18n';
import './EmptyState.scss';

const EmptyStatePattern = props => {
  const {
    documentation,
    action,
    secondaryActions,
    icon,
    iconColor,
    header,
    description,
    variant,
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
      url, // eslint-disable-line react/prop-types
    } = documentation;
    return (
      <span>
        {label}
        <a href={url}>{buttonLabel}</a>
      </span>
    );
  };

  return (
    <EmptyState variant={variant}>
      <span className="empty-state-icon">
        <EmptyStateIcon icon={icon} color={iconColor || undefined} />
      </span>
      <Title headingLevel="h4" size="xl">
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
  icon: PlusCircleIcon,
  secondaryActions: [],
  documentation: {
    url: '#',
  },
  action: null,
  iconType: 'pf',
  variant: EmptyStateVariant.large,
};

export default EmptyStatePattern;
