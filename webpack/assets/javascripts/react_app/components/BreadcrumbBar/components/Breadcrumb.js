import React from 'react';
import PropTypes from 'prop-types';
import { Breadcrumb as PfBreadcrumb } from 'patternfly-react';
import 'patternfly-react/dist/sass/_breadcrumb.scss';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import './Breadcrumbs.scss';

const Breadcrumb = ({
  items,
  title,
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
    <PfBreadcrumb title={title} {...props}>
      {items.map((item, index) => {
        const active = index === items.length - 1;
        const {
          caption,
          caption: { icon, text },
        } = item;
        const overrideTitle = active && titleReplacement;
        const itemTitle = overrideTitle || text || caption;
        const inner = active ? (
          <EllipsisWithTooltip placement="bottom">
            {itemTitle}
          </EllipsisWithTooltip>
        ) : (
          itemTitle
        );

        return (
          <PfBreadcrumb.Item
            key={index}
            active={active}
            onClick={item.onClick}
            href={item.url}
            title={itemTitle}
            className={icon && active && 'breadcrumb-item-with-icon'}
          >
            {icon && <img src={icon.url} alt={icon.alt} title={icon.alt} />}{' '}
            {inner}
          </PfBreadcrumb.Item>
        );
      })}
      {children}
    </PfBreadcrumb>
  );
};

Breadcrumb.propTypes = {
  children: PropTypes.node,
  title: PropTypes.bool,
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
  title: false,
  isTitle: false,
  items: [],
  titleReplacement: null,
};

export default Breadcrumb;
