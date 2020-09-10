import {
  addDays,
  addMonths,
  isEqualDate,
  isWeekend,
  getMonthStart,
} from './helpers';

describe('addDays ', () => {
  const date = new Date('2/21/2019 , 2:22:31 PM');
  test('same month', () => {
    const newDate = addDays(date, 2);
    expect(newDate).toEqual(new Date('2/23/2019 , 2:22:31 PM'));
  });
  test('different month', () => {
    const newDate = addDays(date, 20);
    expect(newDate).toEqual(new Date('3/13/2019 , 2:22:31 PM'));
  });
  test('negative amount', () => {
    const newDate = addDays(date, -2);
    expect(newDate).toEqual(new Date('2/19/2019 , 2:22:31 PM'));
  });
});

describe('addMonths ', () => {
  const date = new Date('2/21/2019, 2:22:31 PM');
  test('same year', () => {
    const newDate = addMonths(date, 2);
    expect(newDate).toEqual(new Date('4/21/2019, 2:22:31 PM'));
  });
  test('different year', () => {
    const newDate = addMonths(date, 13);
    expect(newDate).toEqual(new Date('3/21/2020, 2:22:31 PM'));
  });
  test('negative amount', () => {
    const newDate = addMonths(date, -1);
    expect(newDate).toEqual(new Date('1/21/2019, 2:22:31 PM'));
  });
});

describe('isEqualDate ', () => {
  const date = new Date('2/21/2019 , 2:22:31 PM');
  test('equal', () => {
    const date2 = new Date('2/21/2019 , 6:22:31 PM');
    expect(isEqualDate(date, date2)).toBeTruthy();
  });
  test('not equal', () => {
    const date2 = new Date('2/22/2019 , 6:22:31 PM');
    expect(isEqualDate(date, date2)).toBeFalsy();
  });
});

describe('isWeekend ', () => {
  test('not weekend', () => {
    const date = new Date('2/21/2019 , 6:22:31 PM');
    expect(isWeekend(date)).toBeFalsy();
  });
  test('is weekend', () => {
    const date = new Date('2/23/2019 , 6:22:31 PM');
    expect(isWeekend(date)).toBeTruthy();
  });
});

describe('getMonthStart ', () => {
  test('already strart of the month', () => {
    const date = new Date('2/1/2019 , 6:22:31 PM');
    expect(getMonthStart(date)).toEqual(new Date('2/1/2019 , 6:22:31 PM'));
  });
  test('muidlle of the month', () => {
    const date = new Date('2/23/2019 , 6:22:31 PM');
    expect(getMonthStart(date)).toEqual(new Date('2/1/2019 , 6:22:31 PM'));
  });
});
