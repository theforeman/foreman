import React from 'react';
import PropTypes from 'prop-types';
import { Banner } from '@patternfly/react-core';

const getContrastColor = backgroundColor => {
  const hexToRgb = hex => {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
      ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16),
        }
      : null;
  };
  backgroundColor = hexToRgb(backgroundColor);
  // Calculate the relative luminance of the background color
  const luminance =
    (0.2126 * backgroundColor.r +
      0.7152 * backgroundColor.g +
      0.0722 * backgroundColor.b) /
    255;

  // Choose black or white text based on the relative luminance
  return luminance > 0.5 ? 'black' : 'white';
};
const validateHexColor = instanceColor => {
  // Check if the string is a valid hex color code
  if (/^#([0-9A-Fa-f]{3}){1,2}$/.test(instanceColor)) {
    return instanceColor;
  }
  return '#000000';
};

export const InstanceBanner = ({ data }) => {
  if (!data || !data.instance_title) {
    return null;
  }
  const instance = data.instance_title;
  const instanceColor = validateHexColor(data.instance_color);
  return (
    instance && (
      <Banner
        isSticky
        style={{ '--pf-v5-c-banner--BackgroundColor': instanceColor }}
        className="instance-banner"
      >
        <div
          style={{
            color: getContrastColor(instanceColor),
          }}
        >
          {instance}
        </div>
      </Banner>
    )
  );
};

InstanceBanner.propTypes = {
  data: PropTypes.shape({
    instance_title: PropTypes.string,
    instance_color: PropTypes.string,
  }),
};

InstanceBanner.defaultProps = {
  data: {},
};
