import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import {
  Breadcrumb as PfBreadcrumb,
  BreadcrumbItem,
} from '@patternfly/react-core';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import './Breadcrumbs.scss';

const Breadcrumb = ({
  items,
  isTitle,
  titleReplacement,
  children,
  ...props
}) => {
  if (isTitle) {
    return (
      <div className="form-group">
        <h1>{items[0].caption}</h1>
      </div>
    );
  }

  return (
    <PfBreadcrumb {...props}>
      {items.map((item, index) => {
        const active = index === items.length - 1;
        const { caption, url, onClick } = item;
        const { icon, text } = caption || {};

        const overrideTitle = active && titleReplacement;
        const itemTitle = overrideTitle || text || caption || '';

        if (!icon && !itemTitle) return null;

        const inner = active ? (
          <EllipsisWithTooltip placement="bottom">
            {itemTitle}
          </EllipsisWithTooltip>
        ) : (
          itemTitle
        );

        return (
          <BreadcrumbItem
            key={index}
            isActive={active}
            onClick={onClick}
            to={url}
            className={classNames('breadcrumb-item', {
              active,
              'breadcrumb-item-with-icon': icon && active,
            })}
          >
            {icon && <img src={icon.url} alt={icon.alt} title={icon.alt} />}{' '}
            {inner}
            {active && children}
          </BreadcrumbItem>
        );
      })}
    </PfBreadcrumb>
  );
};

Breadcrumb.propTypes = {
  children: PropTypes.node,
  titleReplacement: PropTypes.string,
  isTitle: PropTypes.bool,
  items: PropTypes.arrayOf(
    PropTypes.shape({
      caption: PropTypes.oneOfType([
        PropTypes.string.isRequired,
        PropTypes.shape({
          icon: PropTypes.shape({
            url: PropTypes.string,
            alt: PropTypes.string,
          }),
          text: PropTypes.string,
        }),
      ]),
      url: PropTypes.string,
    })
  ),
};

Breadcrumb.defaultProps = {
  children: null,
  isTitle: false,
  items: [],
  titleReplacement: null,
};

export default Breadcrumb;
