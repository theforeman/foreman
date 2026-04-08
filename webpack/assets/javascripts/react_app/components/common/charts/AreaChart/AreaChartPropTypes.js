import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';
import { noop } from '../../../../common/helpers';

export const areaChartPropTypes = {
  data: PropTypes.arrayOf(PropTypes.array),
  onclick: PropTypes.func,
  noDataMsg: PropTypes.string,
  config: PropTypes.oneOf(['timeseries']),
  xAxisDataLabel: PropTypes.string,
  yAxisLabel: PropTypes.string,
  size: PropTypes.shape({
    height: PropTypes.number,
    width: PropTypes.number,
  }),
  unloadData: PropTypes.bool,
  yAxisLabelOffset: PropTypes.number,
  chartPadding: PropTypes.shape({
    bottom: PropTypes.number,
    left: PropTypes.number,
    right: PropTypes.number,
    top: PropTypes.number,
  }),
  voronoiPadding: PropTypes.shape({
    bottom: PropTypes.number,
    left: PropTypes.number,
    right: PropTypes.number,
    top: PropTypes.number,
  }),
};

export const areaChartDefaultProps = {
  data: null,
  onclick: noop,
  noDataMsg: __('No data available'),
  config: 'timeseries',
  xAxisDataLabel: 'time',
  yAxisLabel: '',
  size: undefined,
  unloadData: false,
  yAxisLabelOffset: -12,
  chartPadding: undefined,
  voronoiPadding: undefined,
};
