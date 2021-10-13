import { useState } from 'react';

export const useInternalValue = (value, options) => {
  const defaultVal = value
    .map((v) => options.find((opt) => opt.value === v))
    .filter((v) => !!v);
  return useState(defaultVal);
};
