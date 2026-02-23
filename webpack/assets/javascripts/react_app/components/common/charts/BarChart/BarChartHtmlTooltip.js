import React from 'react';
import PropTypes from 'prop-types';
import { Divider } from '@patternfly/react-core';
import { translate as __ } from '../../../../common/I18n';

const BarChartHtmlTooltip = ({
  x,
  y,
  datum,
  active,
  activePoints,
  dimensions,
  tooltipWidth,
  tooltipHeight,
  tooltipPadding,
  getTooltipTitle,
  getTooltipValue,
  getLegendColor,
}) => {
  const activePoint = activePoints?.[0];
  const resolvedDatum = activePoint?.datum ?? activePoint ?? datum;
  const isActive = Boolean(activePoint) || active === true;

  if (!isActive || !resolvedDatum) return null;

  const tooltipTitle = getTooltipTitle(resolvedDatum);
  const value = getTooltipValue(resolvedDatum);
  const color = getLegendColor({ datum: resolvedDatum });

  const idealX = x - tooltipWidth / 2;
  const finalX = Math.min(Math.max(idealX, 0), dimensions.width - tooltipWidth);

  const fitsAbove = y - tooltipHeight - tooltipPadding > 0;
  const finalY = fitsAbove
    ? y - tooltipHeight - tooltipPadding
    : y + tooltipPadding;

  return (
    <g>
      <foreignObject
        height={tooltipHeight}
        width={tooltipWidth}
        x={finalX}
        y={finalY}
      >
        <div
          className="bar-chart__tooltip"
          role="tooltip"
          xmlns="http://www.w3.org/1999/xhtml"
        >
          <div className="bar-chart__tooltip-title">{tooltipTitle}</div>
          <Divider className="bar-chart__tooltip-divider" />
          <div className="bar-chart__tooltip-row">
            <span
              className="bar-chart__tooltip-swatch"
              style={{ '--bar-chart-legend-color': color }}
            />
            <span>{__('Value')}:</span>
            <span className="bar-chart__tooltip-value">{value}</span>
          </div>
        </div>
      </foreignObject>
    </g>
  );
};

BarChartHtmlTooltip.propTypes = {
  x: PropTypes.number,
  y: PropTypes.number,
  datum: PropTypes.object,
  active: PropTypes.bool,
  activePoints: PropTypes.array,
  dimensions: PropTypes.shape({
    width: PropTypes.number.isRequired,
    height: PropTypes.number.isRequired,
  }).isRequired,
  tooltipWidth: PropTypes.number.isRequired,
  tooltipHeight: PropTypes.number.isRequired,
  tooltipPadding: PropTypes.number.isRequired,
  getTooltipTitle: PropTypes.func.isRequired,
  getTooltipValue: PropTypes.func.isRequired,
  getLegendColor: PropTypes.func.isRequired,
};

BarChartHtmlTooltip.defaultProps = {
  x: undefined,
  y: undefined,
  datum: null,
  active: false,
  activePoints: undefined,
};

export default BarChartHtmlTooltip;
