import { cloneElement, isValidElement } from 'react';
import PropTypes from 'prop-types';

const Slot = ({ fills, id, multi, children = null, ...props }) => {
  const addProps = object => {
    if (multi && !object.key) {
      // eslint-disable-next-line no-console
      console.warn(
        `Please add a key attribute to multiple fills [component - ${object.type.name}]`
      );
    }

    if (isValidElement(object)) {
      return cloneElement(object, { ...props });
    }

    if (!children) {
      throw new Error('Slot with override props must have a child');
    }

    return cloneElement(children, { ...props, ...object });
  };

  if (fills.length) return fills.map(component => addProps(component));
  return children;
};

Slot.propTypes = {
  fills: PropTypes.array,
  id: PropTypes.string.isRequired,
  multi: PropTypes.bool,
  children: PropTypes.node,
};

Slot.defaultProps = {
  fills: [],
  multi: false,
  children: undefined,
};

export default Slot;
