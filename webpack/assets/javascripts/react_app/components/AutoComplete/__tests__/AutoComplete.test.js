import React from 'react';
import { mount } from '@theforeman/test';
import lodash from 'lodash';
import AutoComplete from '../AutoComplete';
import { AutoCompleteProps } from '../AutoComplete.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import { KEYCODES } from '../../../common/keyCodes';
import { TRIGGERS } from '../AutoCompleteConstants';
import { noop } from '../../../common/helpers';

lodash.debounce = jest.fn(fn => fn);

const getProps = () => ({
  ...AutoCompleteProps,
  getResults: jest.fn(),
  resetData: jest.fn(),
  initialUpdate: jest.fn(),
  handleSearch: jest.fn(),
});

const fixtures = {
  'renders AutoComplete': AutoCompleteProps,
};
describe('AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(AutoComplete, fixtures);
  });

  describe('triggering', () => {
    it('initial query should update query on componentDidMount', () => {
      const props = getProps();
      mount(<AutoComplete {...props} />);
      expect(props.initialUpdate.mock.calls).toHaveLength(1);
    });

    it('input focus should call getResults', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} results={[]} />);
      const instance = component.instance();
      const emptyEvent = { target: { value: '' } };
      expect(props.getResults.mock.calls).toHaveLength(0);
      instance.handleInputFocus(emptyEvent);
      expect(props.getResults.mock.calls).toHaveLength(1);
    });

    it('pressing "forward-slash" should trigger focus', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} useKeyShortcuts />);
      const instance = component.instance();
      const typeahead = instance._typeahead.current.getInstance();
      typeahead.focus = jest.fn();
      expect(typeahead.focus.mock.calls).toHaveLength(0);
      instance.windowKeyPressHandler({
        charCode: KEYCODES.FWD_SLASH,
        preventDefault: noop,
        target: { tagName: 'BODY' },
      });
      expect(typeahead.focus.mock.calls).toHaveLength(1);
    });

    it('pressing "forward-slash" inside an input should not trigger focus', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} />);
      const instance = component.instance();
      const typeahead = instance._typeahead.current.getInstance();
      typeahead.focus = jest.fn();
      expect(typeahead.focus.mock.calls).toHaveLength(0);
      instance.windowKeyPressHandler({
        charCode: KEYCODES.FWD_SLASH,
        preventDefault: noop,
        target: { tagName: 'INPUT' },
      });
      expect(typeahead.focus.mock.calls).toHaveLength(0);
    });

    it('pressing "ESC" should trigger blur', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} />);
      const instance = component.instance();
      const typeahead = instance._typeahead.current.getInstance();
      typeahead.blur = jest.fn();
      expect(typeahead.blur.mock.calls).toHaveLength(0);
      instance.handleKeyDown({ keyCode: KEYCODES.ESC });
      expect(typeahead.blur.mock.calls).toHaveLength(1);
    });

    it('"Enter" keydown should trigger handle search', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} />);
      const instance = component.instance();
      expect(props.handleSearch.mock.calls).toHaveLength(0);
      instance.handleKeyDown({ keyCode: KEYCODES.ENTER });
      expect(props.handleSearch.mock.calls).toHaveLength(1);
    });

    it('input change should call getResult', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} />);
      const instance = component.instance();
      expect(props.getResults.mock.calls).toHaveLength(0);
      instance.handleInputChange();
      expect(props.getResults.mock.calls).toHaveLength(1);
    });

    it('resetData should be called once', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} />);
      expect(props.resetData.mock.calls).toHaveLength(0);
      component.instance().componentWillUnmount();
      expect(props.resetData.mock.calls).toHaveLength(1);
    });

    it('clear button click should call getResult', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} searchQuery="clear btn will appear only when query exists" />);
      expect(props.getResults.mock.calls).toHaveLength(0);
      component
        .find('.autocomplete-clear-button')
        .first()
        .simulate('click');
      expect(props.getResults.mock.calls).toHaveLength(1);
    });

    it('handleResultsChange should call getResult', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} />);
      const instance = component.instance();
      expect(props.getResults.mock.calls).toHaveLength(0);
      instance.handleResultsChange(props.results);
      expect(props.getResults.mock.calls).toHaveLength(1);
      // shouldn't call if there is no result
      instance.handleResultsChange([]);
      expect(props.getResults.mock.calls).toHaveLength(1);
    });

    it('menu should be hidden if no results', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} results={[]} />);
      const mainInput = component.find('.rbt-input-main').first();
      mainInput.simulate('focus', { target: { value: '' } });
      expect(component.find('.rbt-menu').exists()).toBeFalsy();
      component.setProps({ results: props.results });
      mainInput.simulate('focus', { target: { value: '' } });
      expect(component.find('.rbt-menu').exists()).toBeTruthy();
    });

    it('component update with trigger "RESET" should call handleClear which should reset the input and call getResults', () => {
      const props = { ...getProps() };
      const component = mount(<AutoComplete {...props} />);
      expect(props.getResults.mock.calls).toHaveLength(0);
      component.setProps({ trigger: TRIGGERS.RESET });
      expect(props.getResults.mock.calls).toHaveLength(1);
    });
  });
});
