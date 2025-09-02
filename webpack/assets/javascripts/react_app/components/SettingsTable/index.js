import React, { useMemo, useState } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import PropTypes from 'prop-types';
import { Skeleton } from '@patternfly/react-core';

import { selectSettingsByCategory } from '../SettingRecords/SettingRecordsSelectors';
import SettingsTable from './SettingsTable';

const WrappedSettingsTable = ({ category }) => {
  const selector = useMemo(() => selectSettingsByCategory(category), [
    category,
  ]);
  const settings = useSelector(selector, shallowEqual);

  const [pageComplete, setPageComplete] = useState(
    typeof document !== 'undefined' && document.readyState === 'complete'
  );

  const onLoad = () => setPageComplete(true);
  window.addEventListener('load', onLoad, { once: true });

  const showSkeleton = settings === undefined || !pageComplete;

  if (showSkeleton) {
    return (
      <Skeleton
        key={`sk-${category}`}
        width="100%"
        height="70vh"
        aria-label="Loading settings..."
      />
    );
  }

  return <SettingsTable key={`table-${category}`} settings={settings} />;
};

WrappedSettingsTable.propTypes = {
  category: PropTypes.string.isRequired,
};

export default WrappedSettingsTable;
