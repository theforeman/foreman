import React from 'react';
import { ChartLabel, ChartPoint } from '@patternfly/react-charts';
import { chart_color_black_500 as chartColorBlack500 } from '@patternfly/react-tokens';
import './LegendHelpers.scss';

export const getSeriesOpacity = isDimmedByHover => {
  if (isDimmedByHover) return 0.35;
  return 1;
};

// Use chart_color_black_500 for hidden symbol so ChartLegendTooltip skips this item (PatternFly convention).
export const buildLegendData = (chartData, hiddenSeries) =>
  chartData.map(series => {
    const hidden = hiddenSeries.has(series.name);
    return {
      childName: series.name,
      name: series.name,
      ...(hidden && {
        symbol: {
          type: 'eyeSlash',
          fill: chartColorBlack500.var,
        },
      }),
    };
  });

export const getLegendEvents = (chartName, toggleSeries) => ({
  target: `${chartName}-ChartLegend`,
  eventHandlers: {
    onClick: (evt, props) => {
      if (props.datum?.name) toggleSeries(props.datum.name);
      return [];
    },
    onMouseOver: () => [
      { target: 'data', mutation: () => ({ style: { cursor: 'pointer' } }) },
    ],
    onMouseOut: () => [
      { target: 'data', mutation: () => ({ style: { cursor: 'default' } }) },
    ],
  },
});

/** Format a timestamp for axis tick display (matches formatAxisTick output). */
const formatTickForDedup = t => {
  const date = t instanceof Date ? t : new Date(t >= 1e12 ? t : t * 1000);
  return date.toLocaleString(undefined, {
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  });
};

/** Sample x-axis tick values to avoid duplicate labels when many data points fall within the same minute.
 * Returns up to maxTicks evenly-spaced timestamps, deduplicated by formatted label. */
export const getXAxisTickValues = (chartData, maxTicks = 6) => {
  if (!chartData?.[0]?.data?.length) return undefined;
  const dates = chartData[0].data.map(d => d.x);
  const unique = [
    ...new Set(dates.map(d => (d instanceof Date ? d.getTime() : d))),
  ].sort((a, b) => a - b);
  // candidates: either all unique timestamps (if few enough), or maxTicks evenly-spaced
  // samples across the range (indices 0, step, 2*step, ...) to avoid crowding the axis
  const candidates =
    unique.length <= maxTicks
      ? unique.map(ms => new Date(ms))
      : Array.from({ length: maxTicks }, (_, i) => {
          const step = (unique.length - 1) / (maxTicks - 1);
          const idx = Math.round(i * step);
          return new Date(unique[idx]);
        });
  const seen = new Set();
  return candidates.filter(d => {
    const label = formatTickForDedup(d);
    if (seen.has(label)) return false;
    seen.add(label);
    return true;
  });
};

/** Get display text for tooltip; text may be string or array. */
const getTooltipText = text => {
  if (text == null) return '';
  return Array.isArray(text) ? text.join(' ') : String(text);
};

/** Custom tick label anchored at end, with staggered vertical offset to prevent overlap.
 * Wrapped in <g> with <title> for native tooltip on hover when labels are long or truncated. */
/* eslint-disable react/prop-types */
export const XAxisTickLabel = props => {
  const {
    style,
    index = 0,
    yAxisLabelOffset = -12,
    dy: _dyIgnored,
    text,
    ...rest
  } = props;
  const cleanStyle =
    style && typeof style === 'object' && !Array.isArray(style)
      ? { ...style, verticalAnchor: undefined }
      : style;
  const staggerOffset = index % 2 === 1 ? 14 : 0;
  const axisSpacing = 16;
  const tooltipText = getTooltipText(text);
  return (
    <g>
      {tooltipText && <title>{tooltipText}</title>}
      <ChartLabel
        {...rest}
        text={text}
        style={cleanStyle}
        verticalAnchor="end"
        textAnchor="end"
        dy={yAxisLabelOffset + staggerOffset + axisSpacing}
      />
    </g>
  );
};
/* eslint-enable react/prop-types */

export const formatAxisTick = t => {
  let date;
  if (t instanceof Date) {
    date = t;
  } else if (typeof t === 'number' && t >= 1e9) {
    const ms = t >= 1e12 ? t : t * 1000;
    date = new Date(ms);
  } else {
    date = null;
  }
  return date
    ? date.toLocaleString(undefined, {
        month: 'short',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true,
      })
    : t;
};

/** Fixed decimals for normal range; scientific notation for very large magnitudes. */
export const formatYAxisTick = t => {
  const num = Number(t);
  if (Math.abs(num) >= 1e21) {
    return num.toExponential(1);
  }
  return num.toFixed(1);
};

export const formatTooltipTitle = datum => {
  const x = datum?.x ?? datum?._x;
  if (x == null) return '';
  const date = x instanceof Date ? x : new Date(x >= 1e12 ? x : x * 1000);
  const dateStr = date.toLocaleDateString(undefined, {
    month: 'numeric',
    day: 'numeric',
  });
  const timeStr = date.toLocaleTimeString(undefined, {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  });
  return `${dateStr}, ${timeStr}`;
};

/* eslint-disable react/prop-types */
export const InteractiveLegendSymbol = ({
  datum,
  setHoveredSeries,
  toggleSeries,
  ...rest
}) => {
  const handleClick = () => {
    if (datum?.name && toggleSeries) {
      toggleSeries(datum.name);
    }
  };
  return (
    <g
      className="chart-legend-symbol"
      onClick={handleClick}
      onKeyDown={e => e.key === 'Enter' && handleClick()}
      onMouseOver={() => datum?.name && setHoveredSeries(datum.name)}
      onMouseOut={() => setHoveredSeries(null)}
      role="button"
      tabIndex={0}
    >
      <ChartPoint {...rest} datum={datum} />
    </g>
  );
};

export const InteractiveLegendLabel = ({
  datum,
  hiddenSeries,
  hoveredSeries,
  setHoveredSeries,
  toggleSeries,
  ...rest
}) => {
  const isHidden = datum?.name && hiddenSeries.has(datum.name);
  const isHovered = datum?.name && hoveredSeries === datum.name;
  const handleClick = () => {
    if (datum?.name) toggleSeries(datum.name);
  };
  return (
    <g
      className="chart-legend-label"
      data-hidden={isHidden}
      data-hovered={isHovered}
      onClick={handleClick}
      onMouseOver={() => datum?.name && setHoveredSeries(datum.name)}
      onMouseOut={() => setHoveredSeries(null)}
      onKeyDown={e => e.key === 'Enter' && handleClick()}
      role="button"
      tabIndex={0}
    >
      <ChartLabel {...rest} />
    </g>
  );
};
/* eslint-enable react/prop-types */
