import toJson from 'enzyme-to-json';
import { mount, shallow } from 'enzyme';
import React from 'react';
import SearchInput from './';

jest.unmock('./');

describe('Search Input', () => {
  it('should render', () => {
    const wrapper = shallow(<SearchInput searchValue='val' timeout={300} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('shouldnt gain focus', () => {
    const spy = jest.spyOn(SearchInput.prototype, 'gainFocus');
    mount(<SearchInput searchValue='val' timeout={300} />);

    expect(spy).toHaveBeenCalledTimes(0);
  });

  it('should gain focus', () => {
    const spy = jest.spyOn(SearchInput.prototype, 'gainFocus');
    mount(<SearchInput searchValue='val' timeout={300} focus />);

    expect(spy).toHaveBeenCalled();
  });
});
