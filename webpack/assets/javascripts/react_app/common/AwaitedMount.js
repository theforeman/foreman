import PropTypes from 'prop-types';
import { useState, useEffect } from 'react';
import store from '../redux';
import componentRegistry from '../components/componentRegistry';

// Mounts a component after all plugins have been imported to make sure that all plugins are available to the component
export const AwaitedMount = ({ component, data, flattenData }) => {
  const [mounted, setMounted] = useState(false);
  const [mountedComponent, setMountedComponent] = useState(null);
  const [allPluginsImported, setAllPluginsImported] = useState(
    window.allJsLoaded
  );
  async function mountComponent() {
    if (componentRegistry.registry[component]) {
      setMounted(true);
      setMountedComponent(
        componentRegistry.markup(component, {
          data,
          store,
          flattenData,
        })
      );
    } else if (allPluginsImported) {
      const awaitedComponent = componentRegistry.markup(component, {
        data,
        store,
        flattenData,
      });
      setMounted(true);
      setMountedComponent(awaitedComponent);
    }
  }
  const updateAllPluginsImported = e => {
    setAllPluginsImported(true);
  };
  useEffect(() => {
    document.addEventListener('loadJS', updateAllPluginsImported);
    return () => window.removeEventListener('loadJS', updateAllPluginsImported);
  }, []);
  useEffect(() => {
    if (!mounted) mountComponent();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [allPluginsImported]);
  useEffect(() => {
    // Update the component if the data (props) change
    if (allPluginsImported) mountComponent();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [data]);
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
