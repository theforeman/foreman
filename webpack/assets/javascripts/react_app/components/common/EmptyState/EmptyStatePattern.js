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
} from '@patternfly/react-core';
import { emptyStatePatternPropTypes } from './EmptyStatePropTypes';
import { translate as __ } from '../../../common/I18n';
import { iconMapper } from '../Icon/IconMapper';
import './EmptyState.scss';

// Render the icon element as is: PF6 Icon pins its content to body-text size,
// while an unwrapped SVG inherits the empty state's large icon size (as with
// PF5, whose Icon used 1em). Callers can still pass a pre-sized <Icon>.
const resolveIcon = icon =>
  (typeof icon === 'string' ? iconMapper(icon) : icon) || <PlusCircleIcon />;

const EmptyStatePattern = props => {
  const {
    documentation,
    action,
    secondaryActions,
    icon,
    header,
    description,
    variant,
    status,
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
      status={status}
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
  status: undefined,
};

export default EmptyStatePattern;
