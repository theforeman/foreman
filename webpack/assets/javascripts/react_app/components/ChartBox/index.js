import React, { useEffect } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import PropTypes from 'prop-types';
import { CHARTS_DATA } from './ChartBoxConstants';
import { translate as __ } from '../../common/I18n';
import ChartBox from './ChartBox';

import { get } from '../../redux/API';
import {
  selectAPIResponse,
  selectAPIErrorMessage,
  selectAPIStatus,
} from '../../redux/API/APISelectors';

const ConnectedChartBox = ({
  className,
  config,
  noDataMsg,
  errorText,
  type,
  chart,
  tip,
}) => {
  const { id, url, title, search } = chart;
  const key = `${CHARTS_DATA}_${id}`;
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(get({ key, url }));
  }, [key, url, dispatch]);
  const chartData = useSelector(
    (state) => selectAPIResponse(state, key),
    shallowEqual
  );
  const error = useSelector((state) => selectAPIErrorMessage(state, key));
  const status = useSelector((state) => selectAPIStatus(state, key));
  return (
    <ChartBox
      className={className}
      config={config}
      noDataMsg={noDataMsg}
      errorText={errorText || error}
      type={type}
      tip={tip}
      chart={chartData}
      id={id}
      status={status}
      title={title}
      search={search}
    />
  );
};

ConnectedChartBox.propTypes = {
  chart: PropTypes.shape({
    id: PropTypes.string,
    url: PropTypes.string,
    search: PropTypes.string,
    title: PropTypes.string,
  }).isRequired,
  className: PropTypes.string,
  config: PropTypes.string,
  noDataMsg: PropTypes.string,
  errorText: PropTypes.string,
  type: PropTypes.oneOf(['donut', 'bar']).isRequired,
  tip: PropTypes.string,
};

ConnectedChartBox.defaultProps = {
  className: '',
  config: 'regular',
  noDataMsg: __('No data available'),
  errorText: '',
  tip: '',
};

export default ConnectedChartBox;
