import React from 'react';
import PropTypes from 'prop-types';
import { Tab, TabTitleIcon, TabTitleText } from '@patternfly/react-core';

const EditorRadioButton = ({
  eventKey,
  btnView,
  disabled,
  icon,
  onClick,
  stateView,
  title,
}) => (
  <Tab
    eventKey={eventKey}
    key={`${btnView}-navitem`}
    role="presentation"
    ouiaId={`${btnView}-navitem`}
    isDisabled={disabled}
    id={`${btnView}-navitem`}
    onClick={onClick}
    title={
      icon ? (
        <>
          <TabTitleIcon>{icon}</TabTitleIcon>
          <TabTitleText>{title}</TabTitleText>
        </>
      ) : (
        <TabTitleText>{title}</TabTitleText>
      )
    }
  />
);

EditorRadioButton.propTypes = {
  eventKey: PropTypes.number.isRequired,
  btnView: PropTypes.string.isRequired,
  disabled: PropTypes.bool,
  icon: PropTypes.node,
  onClick: PropTypes.func.isRequired,
  stateView: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
};

EditorRadioButton.defaultProps = {
  icon: null,
  disabled: false,
};

export default EditorRadioButton;
