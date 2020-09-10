import { dispatch } from './foreman_store';
import store from './react_app/redux';

jest.unmock('./foreman_store');
jest.unmock('./foreman_actions');
jest.unmock('./react_app/redux');

const spy = jest.spyOn(store, 'dispatch');
describe('Legacy Bridge', () => {
  it('invoke unexist action', () => {
    expect(() => {
      dispatch('DoesntExistAction');
    }).toThrow(`Dispatch failed: action DoesntExistAction doesn't exist`);
  });
  it('invoke an action', () => {
    const breadcrumbTitle = 'new name';
    dispatch('updateBreadcrumbTitle', breadcrumbTitle);
    expect(spy).toHaveBeenCalled();
    expect(store.getState().breadcrumbBar.titleReplacement).toEqual(
      breadcrumbTitle
    );
  });
});
