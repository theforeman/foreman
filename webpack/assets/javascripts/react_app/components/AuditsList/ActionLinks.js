import React from '@theforeman/vendor/react';
import { Col } from '@theforeman/vendor/patternfly-react';
import PropTypes from '@theforeman/vendor/prop-types';

const ActionLinks = ({ allowedActions }) => (
  <Col sm={2} className="actions-btns">
    {allowedActions &&
      allowedActions.map(
        ({ url, css_class: CssClassString, disabled, name, title }, index) => (
          <a
            key={index}
            {...{ className: CssClassString, href: url, disabled }}
          >
            {name || title}
          </a>
        )
      )}
  </Col>
);

ActionLinks.propTypes = {
  allowedActions: PropTypes.arrayOf(
    PropTypes.shape({
      url: PropTypes.string,
      title: PropTypes.string,
      name: PropTypes.string,
      css_class: PropTypes.string,
      disabled: PropTypes.bool,
    })
  ),
};

ActionLinks.defaultProps = {
  allowedActions: [],
};

export default ActionLinks;
