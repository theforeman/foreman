import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { ButtonGroup, Button } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import { SPLIT, UNIFIED } from './DiffConsts';

const btnClass = (stateView, btnView) =>
  classNames('diff-button', { active: stateView === btnView });

const radioButton = (stateView, btnView, changeState) => (
  <Button
    className={btnClass(stateView, btnView)}
    id={`${btnView}-btn`}
    onClick={changeState}
    bsStyle={stateView === btnView ? 'primary' : 'default'}
  >
    {btnView}
  </Button>
);

const DiffRadioButtons = ({ stateView, changeState }) => (
  <div id="diff-radio-buttons">
    <ButtonGroup>
      {radioButton(stateView, __('split'), () => {
        changeState(SPLIT);
      })}
      {radioButton(stateView, __('unified'), () => {
        changeState(UNIFIED);
      })}
    </ButtonGroup>
  </div>
);

DiffRadioButtons.propTypes = {
  stateView: PropTypes.string.isRequired,
  changeState: PropTypes.func.isRequired,
};

export default DiffRadioButtons;
