import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../common/helpers';
import Actions from '../common/forms/Actions';

export default class SubmitCancelButtons extends React.Component {
  componentDidMount() {
    this.props.onMount();
  }
  render() {
    return (
      <Actions
        submitting={this.props.submitting}
        disabled={this.props.disabled}
        onCancel={() => {
          this.props.onCancel();
          this.props.replacer.replace(this.props.data.cancelPath);
        }}
        onSubmitClick={this.props.onSubmit}
      />
    );
  }
}

SubmitCancelButtons.propTypes = {
  data: PropTypes.shape({
    cancelPath: PropTypes.string,
  }),
  disabled: PropTypes.bool,
  submitting: PropTypes.bool,
  onSubmit: PropTypes.func,
  onCancel: PropTypes.func,
  onMount: PropTypes.func,
  replacer: PropTypes.shape({
    replace: PropTypes.func,
  }),
};

SubmitCancelButtons.defaultProps = {
  data: { cancelPath: '/' },
  onCancel: () => {},
  onSubmit: noop,
  onMount: noop,
  replacer: { replace: noop },
  submitting: false,
  disabled: false,
};
