import uuidV1 from 'uuid/v1';
import Immutable from 'seamless-immutable';
import {
  donutChartConfig,
  donutLargeChartConfig,
  donutMediumChartConfig,
  barChartConfig,
  mediumBarChartConfig,
  smallBarChartConfig,
  lineChartConfig,
  timeseriesLineChartConfig,
  timeseriesAreaChartConfig,
} from './ChartService.consts';

const chartsSizeConfig = {
  area: {
    timeseries: timeseriesAreaChartConfig,
  },
  bar: {
    regular: barChartConfig,
    small: smallBarChartConfig,
    medium: mediumBarChartConfig,
  },
  donut: {
    regular: donutChartConfig,
    medium: donutMediumChartConfig,
    large: donutLargeChartConfig,
  },
  line: {
    regular: lineChartConfig,
    timeseries: timeseriesLineChartConfig,
  },
};

const doDataExist = data => {
  if (!data || data.length === 0) {
    return false;
  }
  return data.reduce((curr, next) => {
    const value = next[1];

    return value !== 0 ? true : curr;
  }, false);
};

const getColors = data =>
  data.reduce((curr, next) => {
    const key = next[0];
    const color = next[2];

    return color ? { ...curr, [key]: color } : curr;
  }, {});

export const getChartConfig = ({
  type,
  data,
  config,
  onclick,
  id = uuidV1(),
}) => {
  const chartConfigForType = chartsSizeConfig[type][config];
  const colors = getColors(data);
  const colorsSize = Object.keys(colors).length;
  const dataExists = doDataExist(data);
  const longNames = {};

  let dataWithShortNames = [];

  if (dataExists) {
    dataWithShortNames = data.map(val => {
      const item = Immutable.asMutable(val.slice());
      const longName = item[0];
      item[0] = item[0].length > 30 ? `${val[0].substring(0, 10)}...` : item[0];
      longNames[item[0]] = longName;
      return item;
    });
  }

  return {
    ...chartConfigForType,
    id,
    data: {
      columns: dataExists ? dataWithShortNames : [],
      onclick,
      ...(colorsSize > 0 ? { colors } : {}),
    },
    // eslint-disable-next-line no-shadow
    tooltip: { format: { name: (name, ratio, id, idx) => longNames[id] } },

    onrendered: () => {
      dataWithShortNames.forEach(colData => {
        const nameOfClass = colData[0].replace(/\W/g, '-');
        const selector = `.c3-legend-item-${nameOfClass} > title`;
        // eslint-disable-next-line no-undef
        const hasTooltip = d3.select(selector)[0][0];

        if (!hasTooltip) {
          // eslint-disable-next-line no-undef
          d3.select(`.c3-legend-item-${nameOfClass}`)
            .append('svg:title')
            .text(longNames[colData[0]]);
        }
      });
    },
  };
};

// PF5 Victory Charts Configuration
export const getDonutChartConfigPF5 = ({
  data,
  config,
  onclick,
  searchUrl,
  searchFilters,
  title,
  id = uuidV1(),
}) => {
  const chartConfigForType = chartsSizeConfig.donut[config];
  const dataExists = doDataExist(data);

  if (!dataExists) {
    return { data: [] };
  }

  // Transform data from [label, value, color] to Victory format
  const transformedData = [];
  const colorScale = [];

  data.forEach(item => {
    const [label, value, color] = item;
    transformedData.push({ x: label, y: value, name: label });

    if (color) {
      colorScale.push(color);
    }
  });

  const isClickable = onclick || searchUrl;
  const eventHandlers = {
    onMouseOver: () => [
      {
        target: 'data',
        eventKey: 'all',
        mutation: props => ({ style: { ...props.style, opacity: 0.3 } }),
      },
      {
        target: 'data',
        mutation: props => ({
          style: { ...props.style, opacity: 1 },
          active: true,
        }),
      },
      {
        target: 'labels',
        mutation: () => ({ active: true }),
      },
    ],
    onMouseOut: () => [
      {
        target: 'data',
        eventKey: 'all',
        mutation: props => ({
          style: { ...props.style, opacity: 1 },
          active: false,
        }),
      },
      {
        target: 'labels',
        mutation: () => ({ active: false }),
      },
    ],
  };

  if (isClickable) {
    eventHandlers.onClick = (event, props) => {
      const { datum } = props;
      const fullLabel = datum.name || datum.x;

      // Create data object compatible with onclick handler
      const clickData = {
        id: fullLabel,
        name: datum.x,
        value: datum.y,
      };

      if (onclick) {
        onclick(clickData, event);
      }

      if (searchUrl) {
        navigateToSearch(searchUrl, searchFilters || {}, clickData);
      }
    };
    eventHandlers.onMouseEnter = () => {
      document.body.style.cursor = 'pointer';
      return null;
    };
    eventHandlers.onMouseLeave = () => {
      document.body.style.cursor = 'default';
      return null;
    };
  }

  const events = [
    {
      target: 'data',
      eventHandlers,
    },
  ];

  // Calculate total for percentage display in tooltips
  const total = transformedData.reduce((sum, item) => sum + item.y, 0);

  // Configure labels to show full name and percentage in tooltip
  const labels = ({ datum }) => {
    const percentage =
      total > 0 ? ((datum.y / total) * 100).toFixed(title?.precision ?? 1) : 0;
    return `${datum.name}: ${percentage}%`;
  };

  return {
    id,
    data: transformedData,
    colorScale: colorScale.length > 0 ? colorScale : undefined,
    width: chartConfigForType.size.width,
    height: chartConfigForType.size.height,
    padding: chartConfigForType.padding,
    innerRadius: chartConfigForType.innerRadius,
    labels,
    events,
  };
};

export const navigateToSearch = (url, searchFilters, data) => {
  let val = searchFilters[data.id] || data.id;
  let setUrl;

  window.tfm.tools.showSpinner();

  if (url.includes('~VAL1~') || url.includes('~VAL2~')) {
    const vals = val.split(' ');

    const val1 = encodeURIComponent(vals[0]);
    const val2 = encodeURIComponent(vals[1]);

    setUrl = url.replace('~VAL1~', val1).replace('~VAL2~', val2);
  } else {
    if (val.includes(' ')) {
      val = encodeURIComponent(val);
    }
    setUrl = url.replace('~VAL~', val);
  }
  window.location.href = setUrl;
};
