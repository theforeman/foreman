import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';
import FormField from '../../common/forms/FormField';

import { COMMON_PARAM_TYPES } from '../CommonParamFormConsts';

const TypeField = ({ selectedType, onChange }) => {
  const helpContent = (
    <Fragment>
      <dt>String</dt>
      <dd>{__('Everything turns into a string.')}</dd>
      <dt>Boolean</dt>
      <dd>{__('true / false')}</dd>
      <dt>Integer</dt>
      <dd>{__('Integer numbers only, can be negative.')}</dd>
      <dt>Real</dt>
      <dd>{__('Accept any numerical input.')}</dd>
      <dt>Array</dt>
      <dd>
        {__('A valid JSON or YAML input, that must evaluate to an array.')}
        <br />
        {__('Example')}:&nbsp;<code>[&quot;some-value&quot;, 123, true]</code>
      </dd>
      <dt>Hash</dt>
      <dd>
        {__(
          'A valid JSON or YAML input, that must evaluate to an object/map/dict/hash.'
        )}
      </dd>
      <dd>
        {__('Examples')}:<br />
        <code>
          &#123;&quot;key&quot; =&#62; &quot;value&quot;&#125;
          <br />
          key: value
        </code>
      </dd>
      <dt>YAML</dt>
      <dd>
        {__('Any valid YAML input.')} {__('Example')}:&nbsp;
        <code>key: value</code>
      </dd>
      <dt>JSON</dt>
      <dd>
        {__('Any valid JSON input.')} {__('Example')}:&nbsp;
        <code>&#123;&quot;key&quot;: &quot;value&quot;&#125;</code>
      </dd>
    </Fragment>
  );

  return (
    <FormField label={__('Parameter Type')} labelHelp={helpContent}>
      <select
        id="common_parameter_parameter_type"
        name="common_parameter[parameter_type]"
        value={selectedType}
        onChange={e => onChange(e.target.value)}
        className="form-control without_select2"
      >
        {COMMON_PARAM_TYPES.map(item => (
          <option value={item.value} key={item.value}>
            {item.label}
          </option>
        ))}
      </select>
    </FormField>
  );
};

TypeField.propTypes = {
  selectedType: PropTypes.string,
  onChange: PropTypes.func.isRequired,
};

TypeField.defaultProps = {
  selectedType: '',
};

export default TypeField;
