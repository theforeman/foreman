import React from 'react';
import PropTypes from 'prop-types';

class Fill extends React.Component {
  componentDidMount() {
    const {
      children,
      overrideProps,
      registerFillComponent,
      id,
      weight,
      fillId,
    } = this.props;

    registerFillComponent(id, overrideProps, fillId, children, weight);
  }
  componentWillUnmount() {
    const { id, unregisterFillComponent, fillId } = this.props;
    unregisterFillComponent(id, fillId);
  }
  render() {
    return null;
  }
}

Fill.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.object]),
  registerFillComponent: PropTypes.func.isRequired,
  unregisterFillComponent: PropTypes.func.isRequired,
  id: PropTypes.string.isRequired,
  weight: PropTypes.number.isRequired,
  fillId: PropTypes.string.isRequired,
  overrideProps: PropTypes.object,
};

Fill.defaultProps = {
  children: undefined,
  overrideProps: undefined,
};

export default Fill;
