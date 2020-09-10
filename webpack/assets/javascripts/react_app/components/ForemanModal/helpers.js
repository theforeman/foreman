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
  const headerChild =
    children.find(child => child.type === ForemanModalHeader) || null;
  const footerChild =
    children.find(child => child.type === ForemanModalFooter) || null;
  const otherChildren = children.filter(
    child =>
      child &&
      // child.type !== undefined &&
      child !== headerChild &&
      child !== footerChild
  );
  return { headerChild, footerChild, otherChildren };
};
