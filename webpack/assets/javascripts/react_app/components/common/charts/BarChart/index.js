import React from 'react';
import PropTypes from 'prop-types';
import {
  Chart,
  ChartBar,
  ChartAxis,
  ChartLabel,
  ChartThemeColor,
  ChartTooltip,
  ChartVoronoiContainer,
  getTheme,
} from '@patternfly/react-charts';
import { Icon } from '@patternfly/react-core';
import { InfoCircleIcon } from '@patternfly/react-icons';
import { noop } from '../../../../common/helpers';
import { translate as __ } from '../../../../common/I18n';
import EmptyState from '../../EmptyState';
import BarChartHtmlTooltip from './BarChartHtmlTooltip';
import './BarChart.scss';

const transformData = rawData => {
  if (!rawData || !Array.isArray(rawData)) return [];

  return rawData.map(item => ({
    x: item?.x ?? item[0],
    y: item?.y ?? item[1],
    name: item?.name ?? item?.x ?? item[0],
    color: item?.color ?? (item[2] || undefined),
  }));
};

const getDatumIndex = datum => {
  if (typeof datum?._index === 'number') return datum._index;
  if (typeof datum?.index === 'number') return datum.index;
  return 0;
};

const getTooltipTitle = datum => String(datum?.x ?? datum?.name ?? '');

const getTooltipValue = datum => {
  const value = Number(datum?.y);
  return Number.isFinite(value) ? Number(value).toFixed(1) : '';
};

/** Match native JS: use scientific notation for very large magnitudes (avoids float width bugs). */
const formatYAxisTick = t => {
  const num = Number(t);
  if (Math.abs(num) >= 1e21) {
    return num.toExponential(1);
  }
  return num.toFixed(1);
};

const CHART_WIDTH = 600;
const CHART_HEIGHTS = {
  small: 250,
  medium: 280,
  regular: 300,
};
const CHART_PADDING_BASE = {
  bottom: 60,
  right: 20,
  top: 10,
};
const DOMAIN_PADDING = { x: [30, 25] };
const TOOLTIP = {
  width: 140,
  height: 70,
  padding: 10,
  pointerLength: 8,
  flyoutPadding: 0,
};
const Y_AXIS_LABEL = 20;

const BarChart = ({
  data,
  onclick,
  noDataMsg,
  config,
  title,
  unloadData,
  xAxisLabel,
  yAxisLabel,
  yAxisLabelOffset,
  padding,
}) => {
  const chartData = transformData(data);
  const hasCustomColors = chartData.some(d => d.color);
  const theme = getTheme(ChartThemeColor.multi);
  const colorScale = theme?.bar?.colorScale || theme?.chart?.colorScale || [];
  const getLegendColor = ({ datum }) => {
    if (datum?.color) return datum.color;
    const index = getDatumIndex(datum);
    if (!colorScale.length) {
      return 'var(--pf-v5-global--Color--100)';
    }
    return colorScale[index % colorScale.length];
  };

  // Handle empty data
  if (!chartData.length) {
    return (
      <EmptyState
        variant="xs"
        icon={
          <Icon iconSize="lg">
            <InfoCircleIcon />
          </Icon>
        }
        header={noDataMsg}
      />
    );
  }

  const dimensions = {
    height: CHART_HEIGHTS[config] || CHART_HEIGHTS.regular,
    width: CHART_WIDTH,
  };

  const maxY = Math.max(0, ...chartData.map(d => Number(d.y) || 0));
  const maxLabelLength = formatYAxisTick(maxY).length;
  const leftPadding = maxLabelLength * 8 + 50;
  const chartPadding = {
    ...CHART_PADDING_BASE,
    left: leftPadding,
    ...padding,
  };

  const maxTooltipString = getTooltipValue({ y: maxY });
  const dynamicTooltipWidth = Math.max(
    TOOLTIP.width,
    100 + maxTooltipString.length * 8
  );

  // Handle click events
  const handleBarClick = (event, clickedData) => {
    if (onclick && typeof onclick === 'function') {
      // Transform back to original format for compatibility
      const originalData = [clickedData.name, clickedData.y];
      onclick(originalData);
    }
  };

  return (
    <div
      className={`bar-chart__container bar-chart__container--${config ||
        'regular'}`}
    >
      <Chart
        ariaDesc={title?.text || __('Bar chart')}
        domainPadding={DOMAIN_PADDING}
        height={dimensions.height}
        width={dimensions.width}
        themeColor={ChartThemeColor.multi}
        containerComponent={
          <ChartVoronoiContainer
            labels={() => ' '}
            labelComponent={
              <ChartTooltip
                constrainToVisibleArea
                renderInPortal={false}
                orientation="top"
                pointerLength={TOOLTIP.pointerLength}
                flyoutStyle={{ fill: 'transparent', stroke: 'transparent' }}
                flyoutPadding={TOOLTIP.flyoutPadding}
                flyoutWidth={dynamicTooltipWidth}
                flyoutHeight={TOOLTIP.height}
                labelComponent={
                  <BarChartHtmlTooltip
                    dimensions={dimensions}
                    tooltipWidth={dynamicTooltipWidth}
                    tooltipHeight={TOOLTIP.height}
                    tooltipPadding={TOOLTIP.padding}
                    getTooltipTitle={getTooltipTitle}
                    getTooltipValue={getTooltipValue}
                    getLegendColor={getLegendColor}
                  />
                }
              />
            }
            constrainToVisibleArea
            voronoiDimension="x"
            activateData
            activateLabels
          />
        }
        padding={chartPadding}
      >
        <ChartAxis
          dependentAxis
          showGrid
          label={yAxisLabel}
          tickFormat={formatYAxisTick}
          axisLabelComponent={
            yAxisLabel ? (
              <ChartLabel x={Y_AXIS_LABEL} dy={yAxisLabelOffset} />
            ) : (
              undefined
            )
          }
        />
        <ChartAxis
          label={xAxisLabel}
          tickFormat={t => {
            const str = String(t);
            return str.length > 10 ? `${str.substring(0, 10)}...` : str;
          }}
        />
        <ChartBar
          data={chartData}
          onClick={handleBarClick}
          style={
            hasCustomColors
              ? { data: { fill: chartDatum => chartDatum?.datum?.color } }
              : undefined
          }
        />
      </Chart>
    </div>
  );
};

BarChart.propTypes = {
  data: PropTypes.arrayOf(PropTypes.array),
  onclick: PropTypes.func,
  noDataMsg: PropTypes.string,
  config: PropTypes.string,
  title: PropTypes.shape({
    type: PropTypes.string,
    text: PropTypes.string,
  }),
  unloadData: PropTypes.bool,
  xAxisLabel: PropTypes.string,
  yAxisLabel: PropTypes.string,
  yAxisLabelOffset: PropTypes.number,
  padding: PropTypes.shape({
    top: PropTypes.number,
    bottom: PropTypes.number,
    left: PropTypes.number,
    right: PropTypes.number,
  }),
};

BarChart.defaultProps = {
  data: null,
  onclick: noop,
  noDataMsg: __('No data available'),
  config: 'regular',
  title: { type: 'percent' },
  unloadData: false,
  yAxisLabel: '',
  xAxisLabel: '',
  yAxisLabelOffset: -12,
  padding: undefined,
};

export default BarChart;
