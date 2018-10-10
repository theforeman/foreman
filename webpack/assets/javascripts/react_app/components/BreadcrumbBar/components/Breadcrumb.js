import React from 'react';
import PropTypes from 'prop-types';
import { Breadcrumb as PfBreadcrumb } from 'patternfly-react';
import 'patternfly-react/dist/sass/_breadcrumb.scss';

const Breadcrumb = ({
  items, title, isTitle, titleReplacement, children, ...props
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
        const { caption, caption: { icon, text } } = item;
        const overrideTitle = active && titleReplacement;

        return (
          <PfBreadcrumb.Item
            key={index}
            active={active}
            onClick={item.onClick}
            href={item.url}
            title={item.caption.text || item.caption}
          >
            {icon && <img src={icon} />}
            {' '}
            {overrideTitle || text || caption}
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
  items: PropTypes.arrayOf(PropTypes.shape({
    caption: PropTypes.oneOfType([
      PropTypes.string.isRequired,
      PropTypes.shape({ icon: PropTypes.string, text: PropTypes.string }),
    ]),
    url: PropTypes.string,
  })),
};

Breadcrumb.defaultProps = {
  children: null,
  title: false,
  isTitle: false,
  items: [],
  titleReplacement: null,
};

export default Breadcrumb;
