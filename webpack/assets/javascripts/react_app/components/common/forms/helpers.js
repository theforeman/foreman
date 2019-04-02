const getEventValue = ({ target: { type, checked, value } }) =>
  type === 'checkbox' ? checked : value;

export const makeOnChangeHanler = (onChange, onValueChange) => evt => {
  onChange(evt);
  onValueChange(getEventValue(evt));
};
