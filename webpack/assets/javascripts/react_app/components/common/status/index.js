import React from 'react';
import { connect } from 'react-redux';
import { get } from 'lodash';
import { Icon } from 'patternfly-react';
import { simpleLoader } from '../../common/Loader';
import * as StatusAction from '../../../redux/actions/status/';

export class Status extends React.Component {
  componentDidMount() {
    const { data: { id, type, url }, getStatus } = this.props;
    if (url) {
      getStatus({ id, type }, url);
    }
  }

  render() {
    const {
      status: {
        status, message, error, success,
      },
      getMessage,
    } = this.props;

    if (message && getMessage) {
      return <span>{message[getMessage]}</span>;
    }

    if (status || success !== undefined) {
      if (message && message.warning) {
        return (
          <div title={message.warning.message}>
            <Icon
              type='pf'
              name='warning-triangle-o'
            />
          </div>
        );
      }
      return (
        <div title={typeof message === 'string' ? message : undefined}>
          <Icon
            type='pf'
            name={status === 'OK' || success ? 'ok' : 'error-circle-o'}
          />
        </div>
      );
    }

    if (error) {
      return (
        <div title={message}>
          <Icon
            type='pf'
            name='error-circle-o' />
        </div>
      );
    }

    return simpleLoader('xs');
  }
}

const mapStateToProps = (state, ownProps) => {
  const { type, id } = ownProps.data;
  return {
    status: get(state.status, `${type}.${id}`) || {},
  };
};

export default connect(mapStateToProps, StatusAction)(Status);
