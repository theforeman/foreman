import $ from 'jquery';
import { map } from 'lodash';
import React from 'react';
import PropTypes from 'prop-types';
import { Spinner } from 'patternfly-react';

import { translate as __ } from '../../../common/I18n';
import { noop } from '../../../common/helpers';
import CommonForm from './CommonForm';
import { STATUS } from '../../../constants';
import MessageBox from '../MessageBox';

class Select extends React.Component {
  initializeSelect2() {
    const { allowClear } = this.props;

    if ($.fn.select2) {
      $(this.select).select2({ allowClear });
    }
  }

  attachEvent() {
    const { onChange } = this.props;
    $(this.select)
      .off('change', onChange)
      .on('change', onChange);
  }

  componentDidMount() {
    this.initializeSelect2();
    this.attachEvent();
  }

  componentDidUpdate(prevProps) {
    this.initializeSelect2();

    if (this.props.status !== prevProps.status) {
      this.attachEvent();
    }
  }

  render() {
    const renderOptions = arr =>
      map(arr, (attribute, value) => (
        <option key={value} value={value}>
          {attribute}
        </option>
      ));

    const {
      label,
      className,
      value,
      onChange,
      options,
      disabled,
      status = STATUS.RESOLVED,
      errorMessage = __('An error occured.'),
    } = this.props;

    let content;

    const innerSelect = (
      <div>
        <select
          disabled={disabled}
          ref={select => {
            this.select = select;
          }}
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
        content = <Spinner loading size="sm" />;
        break;
      }
      case STATUS.ERROR: {
        content = <MessageBox icontype="error-circle-o" msg={errorMessage} />;
        break;
      }
      default:
        content = <MessageBox icontype="error-circle-o" msg="Invalid Status" />;
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

Select.propTypes = {
  value: PropTypes.string,
  label: PropTypes.string,
  className: PropTypes.string,
  allowClear: PropTypes.bool,
  disabled: PropTypes.bool,
  options: PropTypes.object,
  status: PropTypes.string,
  errorMessage: PropTypes.string,
  onChange: PropTypes.func,
};

Select.defaultProps = {
  value: '',
  label: '',
  className: '',
  allowClear: false,
  disabled: false,
  options: {},
  status: STATUS.RESOLVED,
  errorMessage: __('An error occured.'),
  onChange: noop,
};

export default Select;
