import React from 'react';
import PropTypes from 'prop-types';

import { Popover, Icon } from '@patternfly/react-core';
import { HelpIcon } from '@patternfly/react-icons';

const LabelIcon = ({ text }) => (
  <Popover bodyContent={text}>
    <button
      className="pf-v5-c-form__group-label-help"
      onClick={e => e.preventDefault()}
    >
      <Icon isInline>
        <HelpIcon />
      </Icon>
    </button>
  </Popover>
);

LabelIcon.propTypes = {
  text: PropTypes.string.isRequired,
};

export default LabelIcon;
