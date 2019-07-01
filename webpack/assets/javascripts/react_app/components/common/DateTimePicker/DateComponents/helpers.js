export const addDays = (date, days) => {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
};

export const addMonths = (date, months) => {
  const result = new Date(date);
  result.setMonth(result.getMonth() + months);
  return result;
};

export const addYears = (date, years) => {
  const result = new Date(date);
  result.setYear(result.getFullYear() + years);
  return result;
};

export const isEqualDate = (date1, date2) =>
  date1.getYear() === date2.getYear() &&
  date1.getMonth() === date2.getMonth() &&
  date1.getDate() === date2.getDate();

export const isWeekend = date => date.getDay() === 6 || date.getDay() === 5;

export const getMonthStart = date => {
  date.setDate(1);
  return date;
};

export const getWeekStart = date => addDays(date, (7 - date.getDay()) % 7);

export const helpers = {
  addDays,
  addMonths,
  isEqualDate,
  isWeekend,
  getMonthStart,
  getWeekStart,
};

export default helpers;
