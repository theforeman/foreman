import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { Bullseye, Radio, Select, Tooltip } from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../../common/I18n';
import './TaxonomySelect.css';

const TaxonomySelect = ({
  headerText,
  taxonomy,
  children,
  radioChecked,
  setRadioChecked,
  ...selectProps
}) => {
  const taxonomyType =
    taxonomy === 'organization' ? __('organization') : __('location');
  const mismatchFixTip = (
    <Tooltip
      position="right"
      content={
        <FormattedMessage
          id={`bulk-assign-${taxonomy}-mismatch-tip`}
          defaultMessage={__(
            'A mismatch happens if there is a resource associated with a host, such as a domain or subnet, and at the same time not associated with the {taxonomy} you want to assign the host to. The option Fix on mismatch will add such a resource to the {taxonomy}, and is therefore the recommended choice.'
          )}
          values={{ taxonomy: taxonomyType }}
        />
      }
    >
      <OutlinedQuestionCircleIcon style={{ marginLeft: '4px' }} />
    </Tooltip>
  );
  const mismatchFailTip = (
    <Tooltip
      position="right"
      content={
        <FormattedMessage
          id={`bulk-assign-${taxonomy}-mismatch-tip`}
          defaultMessage={__(
            'A mismatch happens if there is a resource associated with a host, such as a domain or subnet, and at the same time not associated with the {taxonomy} you want to assign the host to. The option Fail on mismatch will always result in an error message. For example, reassigning a host from one {taxonomy} to another will fail, even if there is no actual mismatch in settings.'
          )}
          values={{ taxonomy: taxonomyType }}
        />
      }
    >
      <OutlinedQuestionCircleIcon style={{ marginLeft: '4px' }} />
    </Tooltip>
  );

  return (
    <div style={{ marginTop: '1em' }}>
      <h3>{headerText}</h3>
      <Select
        className="scrollable-container"
        id={`select-${taxonomy}`}
        ouiaId={`select-${taxonomy}`}
        shouldFocusToggleOnSelect
        {...selectProps}
      >
        {children}
      </Select>
      <Bullseye>
        <div id="mismatch-radio-container">
          <Radio
            isChecked={radioChecked}
            onChange={(_e, checked) => setRadioChecked(checked)}
            name={`radioFixOnMismatch${taxonomy}`}
            label={__('Fix on mismatch')}
            id={`radio-fix-on-mismatch-${taxonomy}`}
            ouiaId={`radio-fix-on-mismatch-${taxonomy}`}
          />
          {mismatchFixTip}
          <Radio
            isChecked={!radioChecked}
            onChange={(_e, checked) => setRadioChecked(!checked)}
            name={`radioFailOnMismatch${taxonomy}`}
            label={__('Fail on mismatch')}
            id={`radio-fail-on-mismatch-${taxonomy}`}
            ouiaId={`radio-fail-on-mismatch-${taxonomy}`}
            style={{ marginLeft: '50px' }}
          />
          {mismatchFailTip}
        </div>
      </Bullseye>
    </div>
  );
};

TaxonomySelect.propTypes = {
  headerText: PropTypes.string,
  taxonomy: PropTypes.string,
  children: PropTypes.node,
  radioChecked: PropTypes.bool,
  setRadioChecked: PropTypes.func,
};

TaxonomySelect.defaultProps = {
  headerText: '',
  taxonomy: '',
  children: [],
  radioChecked: false,
  setRadioChecked: undefined,
};

export default TaxonomySelect;
