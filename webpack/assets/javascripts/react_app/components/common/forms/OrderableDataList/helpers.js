export const normalizeSelectedValues = value => {
  if (value == null || value === '') {
    return [];
  }

  if (Array.isArray(value)) {
    return value.map(String);
  }

  return [String(value)];
};

export const createInitialChosen = (options = [], selectedValues = []) => {
  const optionByValue = Object.fromEntries(
    options.map(option => [String(option.value), option])
  );

  return normalizeSelectedValues(selectedValues)
    .map(value => optionByValue[value])
    .filter(Boolean)
    .map(({ label, value }) => ({ label, value: String(value) }));
};

export const getAvailableToAdd = (options, chosen) => {
  const chosenValues = new Set(chosen.map(item => item.value));
  return options.filter(option => !chosenValues.has(String(option.value)));
};

export const reorderChosen = (chosen, sourceIndex, destIndex) => {
  const nextChosen = [...chosen];
  const [removed] = nextChosen.splice(sourceIndex, 1);
  nextChosen.splice(destIndex, 0, removed);
  return nextChosen;
};

export const chosenValues = chosen => chosen.map(item => item.value);

export const addToChosen = (chosen, option) => [
  ...chosen,
  { label: option.label, value: String(option.value) },
];

export const removeFromChosen = (chosen, value) =>
  chosen.filter(item => item.value !== String(value));
