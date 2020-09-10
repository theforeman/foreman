import React from 'react';
import PropTypes from 'prop-types';

class Fill extends React.Component {
  componentDidMount() {
    const {
      children,
      overrideProps,
      registerFillComponent,
      slotId,
      weight,
      id,
    } = this.props;

    registerFillComponent(slotId, overrideProps, id, children, weight);
  }
  componentWillUnmount() {
    const { slotId, unregisterFillComponent, id } = this.props;

    unregisterFillComponent(slotId, id);
  }
  render() {
    return null;
  }
}

Fill.propTypes = {
  // a component to be injected on a slot
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.object]),
  registerFillComponent: PropTypes.func.isRequired,
  unregisterFillComponent: PropTypes.func.isRequired,
  slotId: PropTypes.string.isRequired,
  // ordering between slot's fills, higher will be rendered first
  weight: PropTypes.number.isRequired,
  // fill's id
  id: PropTypes.string.isRequired,
  // a props object to be injected on the slot's children
  overrideProps: PropTypes.object,
};

Fill.defaultProps = {
  children: undefined,
  overrideProps: undefined,
};

export default Fill;
