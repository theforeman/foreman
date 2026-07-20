export const normalizeOption = option =>
  typeof option === 'string' ? { label: option, value: option } : option;

export const normalizeOptions = (options = []) => options.map(normalizeOption);

export const namesToOptions = names =>
  names.map(name => ({ label: name, value: name }));

export const optionsToNames = options =>
  options.map(option => String(option.value));

export const appendUniqueOptions = (list1, list2) => {
  const existing = new Set(list1.map(option => String(option.value)));
  const unique = list2.filter(option => !existing.has(String(option.value)));

  return [...list1, ...unique];
};

export const moveItems = (removeFrom, addTo, selectedValues) => {
  const selectedSet = new Set(selectedValues.map(String));
  const newRemoveFrom = removeFrom.filter(
    option => !selectedSet.has(String(option.value))
  );
  const moved = selectedValues
    .map(value =>
      removeFrom.find(option => String(option.value) === String(value))
    )
    .filter(Boolean);

  return [newRemoveFrom, appendUniqueOptions(addTo, moved)];
};

export const reorderChosen = (chosenOptions, sourceIndex, destinationIndex) => {
  const nextChosen = [...chosenOptions];
  const [removed] = nextChosen.splice(sourceIndex, 1);
  nextChosen.splice(destinationIndex, 0, removed);

  return nextChosen;
};

export const normalizeSelectedValues = value => {
  if (value == null || value === '') {
    return [];
  }

  if (Array.isArray(value)) {
    return value.map(String);
  }

  return [String(value)];
};

export const createInitialLists = (options = [], selectedValues = []) => {
  const normalizedOptions = normalizeOptions(options);
  const optionByValue = Object.fromEntries(
    normalizedOptions.map(option => [String(option.value), option])
  );
  const chosen = normalizeSelectedValues(selectedValues)
    .map(value => optionByValue[value])
    .filter(Boolean);
  const chosenValueSet = new Set(chosen.map(option => String(option.value)));
  const available = normalizedOptions.filter(
    option => !chosenValueSet.has(String(option.value))
  );

  return { available, chosen };
};

export const chosenValues = chosenOptions =>
  chosenOptions.map(option => String(option.value));
