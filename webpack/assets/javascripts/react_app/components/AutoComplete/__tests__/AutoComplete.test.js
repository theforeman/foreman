import React from 'react';
import { mount } from 'enzyme';
import AutoComplete from '../AutoComplete';
import { AutoCompleteProps } from '../AutoComplete.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import { KEYCODES, TRIGGERS } from '../AutoCompleteConstants';
import { noop } from '../../../common/helpers';

jest.mock('lodash/debounce', () => jest.fn(fn => fn));

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
      const component = mount(<AutoComplete {...props} />);
      const instance = component.instance();
      const typeahead = instance._typeahead.current.getInstance();
      const event = { charCode: KEYCODES.FWD_SLASH, preventDefault: noop };
      typeahead.focus = jest.fn();
      expect(typeahead.focus.mock.calls).toHaveLength(0);
      instance.windowKeyPressHandler(event);
      expect(typeahead.focus.mock.calls).toHaveLength(1);
      component.setProps({ useKeyShortcuts: false });
      instance.windowKeyPressHandler(event);
      expect(typeahead.focus.mock.calls).toHaveLength(1);
    });

    it('pressing "ENTER" while input isn\'t focused should trigger search', () => {
      const props = getProps();
      const component = mount(<AutoComplete {...props} />);
      const instance = component.instance();
      const event = { charCode: KEYCODES.ENTER, preventDefault: noop };
      expect(props.handleSearch.mock.calls).toHaveLength(0);
      instance.windowKeyPressHandler(event);
      expect(props.handleSearch.mock.calls).toHaveLength(1);
      // Shouldn't affect the ENTER listener.
      const falseEvent = new KeyboardEvent('keypress', { keyCode: '999' });
      instance.windowKeyPressHandler(falseEvent);
      expect(props.handleSearch.mock.calls).toHaveLength(1);
      // if useKeyShortcuts is false, the listener shouldn't work.
      component.setProps({ useKeyShortcuts: false });
      instance.windowKeyPressHandler(event);
      expect(props.handleSearch.mock.calls).toHaveLength(1);
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
      // Shouldn't affect the ENTER listener.
      instance.handleKeyDown({ keyCode: '999' });
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
      const component = mount(<AutoComplete {...props} />);
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
      const props = { ...getProps() };
      const component = mount(<AutoComplete {...props} results={[]} />);
      const mainInput = component.find('.rbt-input-main').first();
      mainInput.simulate('focus', { target: { value: '' } });
      expect(component.find('.rbt-menu').exists()).toBeFalsy();
      component.setProps({ results: props.results });
      mainInput.simulate('focus', { target: { value: '' } });
      expect(component.find('.rbt-menu').exists()).toBeTruthy();
    });

    it('should clear the input text when the trigger is reset', () => {
      const props = { ...getProps() };
      const initialQuery = 'test';
      const component = mount(
        <AutoComplete {...props} initialQuery={initialQuery} />
      );
      const typeahead = component.instance()._typeahead.current.getInstance();
      const clearMethod = jest.spyOn(typeahead, 'clear');
      component.setProps({ trigger: TRIGGERS.RESET });
      component.instance().componentDidUpdate(props);
      expect(clearMethod).toHaveBeenCalled();
    });

    it('Reset trigger should call typeahead clear method', () => {
      const props = { ...getProps() };
      const initialQuery = 'test';
      const component = mount(
        <AutoComplete {...props} initialQuery={initialQuery} />
      );
      const typeahead = component.instance()._typeahead.current.getInstance();
      const clearMethod = jest.spyOn(typeahead, 'clear');
      component.setProps({ trigger: TRIGGERS.RESET });
      component.instance().componentDidUpdate(props);
      expect(clearMethod).toHaveBeenCalled();
    });
  });
});
