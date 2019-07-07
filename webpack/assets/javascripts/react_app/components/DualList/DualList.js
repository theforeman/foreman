import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { DualListControlled as PfDualList } from 'patternfly-react';
import { arrangeItemsBySelectedIDs } from './helpers';
import { bindMethods, noop } from '../../common/helpers';
import FormField from '../common/forms/FormField';
import './dual-list.scss';

class DualList extends React.Component {
  constructor(props) {
    super(props);
    bindMethods(this, ['handleInit', 'handleChange']);
  }

  handleInit({ right: { items } }) {
    const { initialUpdate, id } = this.props;
    const selectedItems = items.map(({ label, value }) => ({ label, value }));
    initialUpdate(selectedItems, id);
  }

  handleChange({ right: { items } }) {
    const { onChange, id } = this.props;
    const selectedItems = items.map(({ label, value }) => ({ label, value }));
    onChange(selectedItems, id);
  }

  render() {
    const { inputProps, items, selectedIDs, label, id, error } = this.props;
    const { selectedList, unselectedlist } = arrangeItemsBySelectedIDs(
      items,
      selectedIDs
    );
    return (
      <div id={id}>
        <FormField
          labelSizeClass="col-md-2"
          inputSizeClass="col-md-10"
          label={label}
        >
          <Fragment>
            <PfDualList
              allowHiddenInputs
              onComponentInit={this.handleInit}
              onChange={this.handleChange}
              left={{
                items: unselectedlist,
                inputProps: {
                  className: inputProps.className,
                },
              }}
              right={{
                items: selectedList,
                inputProps,
              }}
            />
            <div className="dual_list_error">{error}</div>
          </Fragment>
        </FormField>
      </div>
    );
  }
}

DualList.propTypes = {
  id: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  error: PropTypes.string,
  inputProps: PropTypes.object,
  items: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      value: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
        .isRequired,
    })
  ),
  selectedIDs: PropTypes.arrayOf(
    PropTypes.oneOfType([PropTypes.string, PropTypes.number])
  ),
  initialUpdate: PropTypes.func,
  onChange: PropTypes.func,
};

DualList.defaultProps = {
  error: null,
  inputProps: {},
  items: [],
  selectedIDs: [],
  initialUpdate: noop,
  onChange: noop,
};

export default DualList;
