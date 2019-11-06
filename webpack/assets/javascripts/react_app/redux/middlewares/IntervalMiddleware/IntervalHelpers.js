export const registeredIntervalException = key =>
  new Error(`There is already an interval running and registered for: ${key}.`);

export const unregisteredIntervalException = key =>
  new Error(`Can't find a registered interval process for: ${key}`);
