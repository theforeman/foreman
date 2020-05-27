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
    if (this.props.useSelect2) {
      this.initializeSelect2();
      this.attachEvent();
    }
  }

  componentDidUpdate(prevProps) {
    if (this.props.useSelect2) {
      this.initializeSelect2();
      if (this.props.status !== prevProps.status) {
        this.attachEvent();
      }
    }
  }

  render() {
    const {
      name,
      label,
      className,
      value,
      onChange,
      options,
      disabled,
      status = STATUS.RESOLVED,
      errorMessage = __('An error occured.'),
    } = this.props;

    const renderOption = ({ val, text, key = null }) => (
      <option value={val} key={key || val}>
        {text}
      </option>
    );

    const renderOptGroup = group => (
      <optgroup label={group.groupLabel} key={group.groupLabel}>
        {renderOptions(group.children)}
      </optgroup>
    );

    const renderOptions = opts => {
      if (Array.isArray(opts)) {
        return opts.map((opt, index) => {
          if (opt.children) return renderOptGroup(opt);
          return renderOption({ key: index, val: opt.value, text: opt.label });
        });
      }
      return map(opts, (text, val) => renderOption({ val, text }));
    };

    let content;

    const innerSelect = (
      <div>
        <select
          name={name}
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
  name: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  label: PropTypes.string,
  className: PropTypes.string,
  allowClear: PropTypes.bool,
  disabled: PropTypes.bool,
  options: PropTypes.oneOfType([PropTypes.array, PropTypes.object]),
  status: PropTypes.string,
  errorMessage: PropTypes.string,
  onChange: PropTypes.func,
  useSelect2: PropTypes.bool,
};

Select.defaultProps = {
  name: null,
  value: undefined,
  label: '',
  className: '',
  allowClear: false,
  disabled: false,
  options: {},
  status: STATUS.RESOLVED,
  errorMessage: __('An error occured.'),
  onChange: noop,
  useSelect2: true,
};

export default Select;
