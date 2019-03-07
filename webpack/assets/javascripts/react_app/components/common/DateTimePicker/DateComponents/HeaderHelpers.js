import { times } from 'lodash';
import { addDays, getWeekStart } from './helpers';

export const getWeekArray = (weekStartsOn, locale) => {
  const weekStart = getWeekStart(new Date());
  const dayFormat =
    Intl.DateTimeFormat(locale, { weekday: 'short' }).format(weekStart).length >
    3
      ? 'narrow'
      : 'short';
  return times(7, i =>
    Intl.DateTimeFormat(locale, { weekday: dayFormat })
      .format(addDays(weekStart, (i + weekStartsOn) % 7))
      .slice(0, 2)
  );
};
