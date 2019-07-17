/* eslint-disable no-console, max-len */

export const deprecate = (oldMethod, newMethod, version) => {
  if (process.env.NODE_ENV !== 'production')
    console.warn(
      `DEPRECATION WARNING: you are using deprecated ${oldMethod}, it will be removed in Foreman ${version}. Use ${newMethod} instead.`
    );
};
export const deprecateObjectProperty = (obj, oldProp, newProp, version) => {
  const oldPropPointer = obj[oldProp];

  Object.defineProperty(obj, oldProp, {
    get: () => {
      deprecate(oldProp, newProp, version);
      return oldPropPointer;
    },
  });
};
