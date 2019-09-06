import React from 'react';
import ForemanModalHeader from './subcomponents/ForemanModalHeader';
import ForemanModalFooter from './subcomponents/ForemanModalFooter';

/**
 * Extract Header and Footer child nodes from ForemanModal.
 * @param  {PropTypes.node} children ForemanModal props.children
 * @return {object} Child nodes separated out into headerChild, footerChild, otherChildren
 */
export const extractModalNodes = children => {
  children = React.Children.toArray(children);
  const headerChild = children.find(child => child.type === ForemanModalHeader);
  const footerChild = children.find(child => child.type === ForemanModalFooter);
  const otherChildren = children.filter(
    child => child !== headerChild && child !== footerChild
  );
  return { headerChild, footerChild, otherChildren };
};
