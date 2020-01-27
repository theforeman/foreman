import React, { useState, useEffect } from 'react';
import Skeleton from 'react-loading-skeleton';
import PropTypes from 'prop-types';
import './styles.css';

const DelayedSkeleton = ({ timeout, count }) => {
  const [render, setRender] = useState(false);

  useEffect(() => {
    const renderSkeletons = setTimeout(() => setRender(true), timeout);
    return () => clearTimeout(renderSkeletons);
  });
  if (render)
    return (
      <div id="loader">
        <Skeleton count={count} />
      </div>
    );
  return null;
};

export default DelayedSkeleton;

DelayedSkeleton.propTypes = {
  timeout: PropTypes.number,
  count: PropTypes.number,
};

DelayedSkeleton.defaultProps = {
  timeout: 250,
  count: 5,
};
