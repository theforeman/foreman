import React, { useMemo } from 'react';
import classNames from 'classnames';
import PropTypes from 'prop-types';
import { PlusCircleIcon } from '@patternfly/react-icons';
import {
  EmptyState,
  EmptyStateVariant,
  EmptyStateBody,
  EmptyStateActions,
  EmptyStateFooter,
  Icon,
} from '@patternfly/react-core';
import { emptyStatePatternPropTypes } from './EmptyStatePropTypes';
import { translate as __ } from '../../../common/I18n';
import { iconMapper } from '../Icon/IconMapper';
import './EmptyState.scss';

const resolveIcon = icon => {
  const iconElement = (typeof icon === 'string' ? iconMapper(icon) : icon) || (
    <PlusCircleIcon size="2x" />
  );
  // Wrap icon in Icon component if it's not already wrapped
  if (
    React.isValidElement(iconElement) &&
    iconElement.type?.displayName !== 'Icon'
  ) {
    return <Icon>{iconElement}</Icon>;
  }
  return iconElement;
};

const EmptyStatePattern = props => {
  const {
    documentation,
    action,
    secondaryActions,
    icon,
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

  // PF6 renders EmptyState's `icon` above the title; children go below it
  const EmptyStateIcon = useMemo(() => {
    const iconElement = resolveIcon(icon);
    const ForemanEmptyStateIcon = ({ className, ...iconProps }) => (
      <span
        className={classNames('empty-state-icon', className)}
        {...iconProps}
      >
        {iconElement}
      </span>
    );
    ForemanEmptyStateIcon.propTypes = { className: PropTypes.string };
    ForemanEmptyStateIcon.defaultProps = { className: undefined };
    return ForemanEmptyStateIcon;
  }, [icon]);

  return (
    <EmptyState
      headingLevel="h5"
      icon={EmptyStateIcon}
      titleText={<>{header}</>}
      variant={variant}
      className="foreman-empty-state"
    >
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
  icon: <PlusCircleIcon />,
  secondaryActions: [],
  documentation: null,
  action: null,
  variant: EmptyStateVariant.xl,
};

export default EmptyStatePattern;
