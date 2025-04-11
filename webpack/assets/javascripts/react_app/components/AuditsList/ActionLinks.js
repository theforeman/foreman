import React from 'react';
import { GridItem, Button } from '@patternfly/react-core';
import PropTypes from 'prop-types';

const ActionLinks = ({ allowedActions }) => (
  <GridItem span={12} className="actions-btns">
    {allowedActions &&
      allowedActions.map(({ url, disabled, name, title }, index) => (
        <Button
          ouiaId="action-links-btn"
          variant="primary"
          component="a"
          size="sm"
          isInline
          key={index}
          href={url}
          isDisabled={disabled}
          className="pf-v5-u-float-right"
        >
          {name || title}
        </Button>
      ))}
  </GridItem>
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
