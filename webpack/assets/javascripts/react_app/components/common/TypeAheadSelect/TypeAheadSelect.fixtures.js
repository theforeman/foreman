import Immutable from 'seamless-immutable';

export const id = 'test_type_ahead_select';
export const options = ['option1', 'option2'];
export const selected = ['option2'];
export const initialState = Immutable({ typeAheadSelect: {} });
export const populatedState = Immutable({
  typeAheadSelect: {
    test_type_ahead_select: {
      options,
      selected,
    },
  },
});

export const props = {
  id,
  options,
  selected,
};
