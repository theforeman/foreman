import React from 'react';
import { Button } from 'patternfly-react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';
import { simpleLoader } from '../../../common/Loader';

const SubmitBtn = ({ isSubmitting, onSubmit, bsStyle, btnText }) => (
  <Button bsStyle={bsStyle} disabled={isSubmitting} onClick={onSubmit}>
    &nbsp;
    {btnText}
    &nbsp;
    {isSubmitting && <span className="fr">{simpleLoader('sm')}</span>}
  </Button>
);

SubmitBtn.propTypes = {
  isSubmitting: PropTypes.bool.isRequired,
  onSubmit: PropTypes.func.isRequired,
  bsStyle: PropTypes.string,
  btnText: PropTypes.string,
};

SubmitBtn.defaultProps = {
  bsStyle: 'primary',
  btnText: __('Submit'),
};

export default SubmitBtn;
