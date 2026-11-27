import PropTypes from 'prop-types';
import { useState, useEffect, useCallback } from 'react';
import store from '../redux';
import componentRegistry from '../components/componentRegistry';

// Mounts a component after all plugins have been imported to make sure that all plugins are available to the component
export const AwaitedMount = ({ component, data, flattenData }) => {
  const [mounted, setMounted] = useState(false);
  const [mountedComponent, setMountedComponent] = useState(null);
  const mountComponent = useCallback(async () => {
    if (componentRegistry.registry[component]) {
      setMounted(true);
      setMountedComponent(
        componentRegistry.markup(component, {
          data,
          store,
          flattenData,
        })
      );
    } else {
      // eslint-disable-next-line no-console
      console.debug(
        `Component not found: ${component}. The script for the component might not have been loaded yet.`
      );
    }
  }, [component, data, flattenData]);
  useEffect(() => {
    document.addEventListener('loadPlugin', mountComponent);
    return () => {
      window.removeEventListener('loadPlugin', mountComponent);
    };
  }, [mountComponent]);
  useEffect(() => {
    mountComponent();
  }, [mountComponent]);
  return mounted ? mountedComponent : null;
};

AwaitedMount.propTypes = {
  component: PropTypes.string.isRequired,
  data: PropTypes.object,
  flattenData: PropTypes.bool,
};
AwaitedMount.defaultProps = {
  data: {},
  flattenData: false,
};
