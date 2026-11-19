import React from 'react';
import PropTypes from 'prop-types';

import { Button, Popover, Icon } from '@patternfly/react-core';
import { HelpIcon } from '@patternfly/react-icons';

const LabelIcon = ({ text }) => (
  <Popover bodyContent={text}>
    <Button
      icon={
        <Icon isInline>
          <HelpIcon />
        </Icon>
      }
      ouiaId="label-icon-help"
      variant="plain"
      aria-label="Help"
      onClick={e => e.preventDefault()}
      isInline
    />
  </Popover>
);

LabelIcon.propTypes = {
  text: PropTypes.string.isRequired,
};

export default LabelIcon;
