import { cloneElement, isValidElement } from 'react';
import uuidV1 from 'uuid/v1';
import PropTypes from 'prop-types';
import { selectComponentByWeight, selectMaxComponent } from './SlotSelectors';

const Slot = ({ fills, id, multi, children, ...props }) => {
  const addProps = object => {
    if (isValidElement(object)) {
      return cloneElement(object, { ...props, key: uuidV1() });
    }

    if (children === undefined) {
      throw new Error('Slot with override props must having children');
    }
    if (typeof object !== 'object') {
      throw new Error(
        'Slot with override props must having props object instead of JSX'
      );
    }
    return cloneElement(children, { ...props, ...object, key: uuidV1() });
  };

  if (Object.keys(fills).length) {
    if (multi) {
      return selectComponentByWeight(id).map(component => addProps(component));
    }
    return addProps(selectMaxComponent(id));
  }
  if (children) return children;
  return null;
};

Slot.propTypes = {
  fills: PropTypes.object.isRequired,
  id: PropTypes.string.isRequired,
  multi: PropTypes.bool,
  children: PropTypes.node,
};

Slot.defaultProps = {
  multi: false,
  children: undefined,
};

export default Slot;
