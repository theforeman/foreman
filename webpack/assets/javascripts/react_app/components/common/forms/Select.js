import $ from 'jquery';
import { map } from 'lodash';
import React from 'react';
import { Spinner } from 'patternfly-react';

import CommonForm from './CommonForm';
import { STATUS } from '../../../constants';
import MessageBox from '../MessageBox';

class Select extends React.Component {
  initializeSelect2() {
    const { allowClear } = this.props;

    if ($.fn.select2) {
      $(this.refs.select)
        .select2({ allowClear: allowClear || false })
        .on('change', this.props.onChange);
    }
  }

  componentDidMount() {
    this.initializeSelect2();
  }

  componentDidUpdate() {
    this.initializeSelect2();
  }

  render() {
    const renderOptions = arr =>
      map(arr, (attribute, value) => (
        <option key={value} value={value}>
          {attribute}
        </option>
      ));

    const {
      label, className = '', value, onChange, options, disabled,
      status = STATUS.RESOLVED, errorMessage = __('An error occured.'),
    } = this.props;

    let content;

    const innerSelect = (
      <div>
      <select
        disabled={disabled}
        ref="select"
        className="form-control"
        value={value}
        onChange={onChange}
      >
        <option />
        {renderOptions(options)}
      </select>
      </div>
    );

    switch (status) {
      case STATUS.RESOLVED: {
        content = innerSelect;
        break;
      }
      case STATUS.PENDING: {
        content = (<Spinner loading size="sm" />);
        break;
      }
      case STATUS.ERROR: {
        content = (<MessageBox icontype="error-circle-o" msg={errorMessage} />);
        break;
      }
      default:
        content = (<MessageBox icontype="error-circle-o" msg="Invalid Status" />);
        break;
    }

    if (!label) {
      return innerSelect;
    }
    return (
      <CommonForm label={label} className={`common-select ${className}`}>
        {content}
      </CommonForm>
    );
  }
}

export default Select;
