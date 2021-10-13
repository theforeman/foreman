import React from 'react';
import PropTypes from 'prop-types';
import componentRegistry from '../../componentRegistry';

const ComponentWrapper = (props) => {
  const { component, componentProps } = props.data;

  if (component === 'ComponentWrapper') {
    throw new Error('Cannot wrap component wrapper');
  }

  const registeredComponent = componentRegistry.getComponent(component);

  if (!registeredComponent) {
    throw new Error('Component name is missing!');
  }

  const Component = registeredComponent.type;

  return <Component {...componentProps} />;
};

ComponentWrapper.propTypes = {
  data: PropTypes.shape({
    componentProps: PropTypes.object,
    component: PropTypes.string.isRequired,
  }).isRequired,
};

export default ComponentWrapper;
