import React, {
  useMemo,
  useState,
  useCallback,
  useRef,
  useEffect,
} from 'react';
import {
  Chart,
  ChartArea,
  ChartAxis,
  ChartGroup,
  ChartStack,
  ChartLegend,
  ChartLegendTooltip,
  ChartLabel,
  ChartThemeColor,
  createContainer,
  getTheme,
} from '@patternfly/react-charts';
import { Icon } from '@patternfly/react-core';
import { InfoCircleIcon } from '@patternfly/react-icons';
import { processChartData, getYTickValues } from './AreaChartHelpers';
import EmptyState from '../../EmptyState';
import {
  buildLegendData,
  formatAxisTick,
  formatTooltipTitle,
  formatYAxisTick,
  getLegendEvents,
  getSeriesOpacity,
  getXAxisTickValues,
  InteractiveLegendLabel,
  InteractiveLegendSymbol,
  XAxisTickLabel,
} from '../helpers/LegendHelpers';
import {
  areaChartPropTypes,
  areaChartDefaultProps,
} from './AreaChartPropTypes';
import './AreaChart.scss';

const DEFAULT_HEIGHT = 250;
const DEFAULT_WIDTH = 800;

/** Left padding is computed from y-axis tick label width. */
const CHART_PADDING_BASE = { bottom: 125, right: 170, top: 50 };
const Y_AXIS_LABEL = 30;
const DEFAULT_VORONOI_PADDING = {
  top: 20,
  left: 20,
  right: 20,
  bottom: 90,
};

const AreaChart = ({
  data,
  onclick,
  noDataMsg,
  config,
  xAxisDataLabel,
  yAxisLabel,
  size,
  unloadData,
  yAxisLabelOffset,
  chartPadding,
  voronoiPadding,
}) => {
  const chartData = useMemo(() => processChartData(data, xAxisDataLabel), [
    data,
    xAxisDataLabel,
  ]);

  const CursorVoronoiContainer = useMemo(
    () => createContainer('voronoi', 'cursor'), // eslint-disable-line spellcheck/spell-checker
    []
  );

  // Hooks must run before any early return (react-hooks/rules-of-hooks)
  const [hiddenSeries, setHiddenSeries] = useState(() => new Set());
  const [hoveredSeries, setHoveredSeries] = useState(null);
  const toggleSeries = useCallback(name => {
    setHiddenSeries(prev => {
      const next = new Set(prev);
      if (next.has(name)) next.delete(name);
      else next.add(name);
      return next;
    });
  }, []);

  const multiTheme = useMemo(
    () => ({
      ...getTheme(ChartThemeColor.multi),
      legend: {
        ...getTheme(ChartThemeColor.multi).legend,
        position: 'right',
      },
    }),
    []
  );
  const colorScale = useMemo(
    () =>
      config === 'timeseries'
        ? multiTheme.stack?.colorScale ?? multiTheme.chart?.colorScale ?? []
        : multiTheme.group?.colorScale ?? multiTheme.chart?.colorScale ?? [],
    [config, multiTheme]
  );
  const visibleSeriesWithIndex = useMemo(
    () =>
      chartData
        ? chartData
            .map((series, i) => ({ series, index: i }))
            .filter(({ series }) => !hiddenSeries.has(series.name))
        : [],
    [chartData, hiddenSeries]
  );

  // Sample tick values to avoid duplicate labels when many data points fall within the same minute.
  const tickValues = useMemo(() => getXAxisTickValues(chartData, 6), [
    chartData,
  ]);

  const yTickValues = useMemo(
    () => getYTickValues(chartData, config, hiddenSeries),
    [chartData, config, hiddenSeries]
  );

  const containerRef = useRef(null);
  const [observedSize, setObservedSize] = useState({
    width: DEFAULT_WIDTH,
    height: DEFAULT_HEIGHT,
  });

  useEffect(() => {
    const el = containerRef.current;
    if (!el || typeof ResizeObserver === 'undefined') return undefined;

    const observer = new ResizeObserver(([entry]) => {
      const { width, height } = entry.contentRect;
      if (width > 0 && height > 0) {
        setObservedSize({ width, height });
      }
    });

    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  if (!chartData) {
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

  const chartHeight = size?.height ?? observedSize.height;
  const chartWidth = size?.width ?? observedSize.width;
  const maxTickLabelLen =
    yTickValues?.length > 0
      ? Math.max(...yTickValues.map(t => formatYAxisTick(t).length))
      : formatYAxisTick(0).length;
  const dynamicLeft = maxTickLabelLen * 8 + 50;
  const padding = {
    ...CHART_PADDING_BASE,
    left: dynamicLeft,
    ...chartPadding,
  };
  const chartName = 'area-chart';
  const legendData = buildLegendData(chartData, hiddenSeries);
  const legendEvents = getLegendEvents(chartName, toggleSeries);
  const ChartWrapper = config === 'timeseries' ? ChartStack : ChartGroup;

  return (
    <div ref={containerRef} className="area-chart-container">
      <Chart
        name={chartName}
        theme={multiTheme}
        themeColor={ChartThemeColor.multi}
        ariaDesc="Area chart"
        containerComponent={
          <CursorVoronoiContainer
            cursorDimension="x"
            labels={({ datum }) => {
              const value =
                datum.y0 !== undefined ? datum.y - datum.y0 : datum.y;
              return formatYAxisTick(value);
            }}
            labelComponent={
              <ChartLegendTooltip
                legendData={legendData}
                title={formatTooltipTitle}
              />
            }
            mouseFollowTooltips
            voronoiDimension="x"
            voronoiPadding={{ ...DEFAULT_VORONOI_PADDING, ...voronoiPadding }}
            constrainToVisibleArea
          />
        }
        height={chartHeight}
        width={chartWidth}
        padding={padding}
        legendData={legendData}
        legendOrientation="vertical"
        legendPosition="right"
        legendComponent={
          <ChartLegend
            dataComponent={
              <InteractiveLegendSymbol
                setHoveredSeries={setHoveredSeries}
                toggleSeries={toggleSeries}
              />
            }
            labelComponent={
              <InteractiveLegendLabel
                hiddenSeries={hiddenSeries}
                hoveredSeries={hoveredSeries}
                setHoveredSeries={setHoveredSeries}
                toggleSeries={toggleSeries}
              />
            }
          />
        }
        events={[
          {
            target: 'data',
            eventHandlers: {
              onClick: () => [
                {
                  target: 'data',
                  // Victory passes datum to mutation; we don't control the props shape
                  mutation: p => {
                    if (onclick && p.datum?.name) onclick({ id: p.datum.name });
                    return null;
                  },
                },
              ],
            },
          },
          legendEvents,
        ]}
      >
        <ChartAxis
          tickValues={tickValues}
          tickFormat={formatAxisTick}
          tickLabelComponent={
            <XAxisTickLabel yAxisLabelOffset={yAxisLabelOffset} />
          }
          style={{ tickLabels: { angle: -45, verticalAnchor: 'end' } }}
        />
        <ChartAxis
          dependentAxis
          showGrid
          label={yAxisLabel}
          tickValues={yTickValues}
          tickFormat={formatYAxisTick}
          axisLabelComponent={
            yAxisLabel ? (
              <ChartLabel x={Y_AXIS_LABEL} dy={yAxisLabelOffset} />
            ) : (
              undefined
            )
          }
        />
        <ChartWrapper>
          {visibleSeriesWithIndex.map(({ series, index }) => (
            <ChartArea
              key={series.name}
              data={series.data}
              name={series.name}
              style={{
                data: {
                  fill: colorScale[index % colorScale.length] ?? undefined,
                  opacity: getSeriesOpacity(
                    hoveredSeries && hoveredSeries !== series.name
                  ),
                },
              }}
            />
          ))}
        </ChartWrapper>
      </Chart>
    </div>
  );
};

AreaChart.propTypes = areaChartPropTypes;
AreaChart.defaultProps = areaChartDefaultProps;

export default AreaChart;
