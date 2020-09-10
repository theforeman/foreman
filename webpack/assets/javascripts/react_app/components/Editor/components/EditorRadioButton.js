import React from 'react';
import PropTypes from 'prop-types';
import { Icon, NavItem } from 'patternfly-react';

const EditorRadioButton = ({
  btnView,
  disabled,
  icon,
  onClick,
  stateView,
  title,
}) => (
  <NavItem
    disabled={disabled}
    active={stateView === btnView}
    id={`${btnView}-navitem`}
    onClick={onClick}
  >
    {icon && <Icon type={icon.type} name={icon.name} />}
    {icon ? ` ${title}` : title}
  </NavItem>
);

EditorRadioButton.propTypes = {
  btnView: PropTypes.string.isRequired,
  disabled: PropTypes.bool,
  icon: PropTypes.object,
  onClick: PropTypes.func.isRequired,
  stateView: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
};

EditorRadioButton.defaultProps = {
  icon: null,
  disabled: false,
};

export default EditorRadioButton;
