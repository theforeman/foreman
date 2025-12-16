import { yyyyMMddFormat } from '@patternfly/react-core';

export const formatTime = time => {
  let now;
  if (time) {
    now = Number.isNaN(Date.parse(time))
      ? new Date(`01/01/2025 ${time}`)
      : new Date(time);
  } else {
    now = new Date();
  }
  return now.toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });
};

export const formatDate = date => {
  const now = date ? new Date(date) : new Date();
  return yyyyMMddFormat(now);
};
