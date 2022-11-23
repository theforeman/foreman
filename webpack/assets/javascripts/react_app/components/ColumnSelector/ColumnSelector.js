import React, { useState } from 'react';
import { PropTypes } from 'prop-types';
import { Button, Modal, ModalVariant, TreeView } from '@patternfly/react-core';
import { ColumnsIcon } from '@patternfly/react-icons';
import { cloneDeep } from 'lodash';
import { translate as __ } from '../../common/I18n';
import API from '../../API';
import { changeQuery } from '../../common/urlHelpers';
import './column-selector.scss';

const ColumnSelector = props => {
  const {
    data: { url, controller, categories, hasPreference },
  } = props;

  const initialColumns = cloneDeep(categories);
  const [isModalOpen, setModalOpen] = useState(false);
  const [selectedColumns, setSelectedColumns] = useState(categories);

  const getColumnKeys = () => {
    const keys = selectedColumns
      .map(category => category.children)
      .flat()
      .map(column => {
        if (column.checkProps.checked) {
          return column.key;
        }
        return null;
      })
      .filter(item => item);
    return keys;
  };

  async function updateTablePreference() {
    if (!hasPreference) {
      await API.post(url, { name: 'hosts', columns: getColumnKeys() });
    } else {
      await API.put(`${url}/${controller}`, { columns: getColumnKeys() });
    }
    changeQuery({});
  }

  const filterItems = (item, checkedItem) => {
    if (item.key === checkedItem.key) {
      return true;
    }

    if (item.children) {
      item.children = item.children
        .map(opt => Object.assign({}, opt))
        .filter(column => filterItems(column, checkedItem));
      return item.children;
    }

    return null;
  };

  const flattenTree = tree => {
    let result = [];
    tree.forEach(item => {
      result.push(item);
      if (item.children) {
        result = result.concat(flattenTree(item.children));
      }
    });
    return result;
  };

  const toggleModal = () => {
    setSelectedColumns(initialColumns);
    setModalOpen(!isModalOpen);
  };

  const updateCheckBox = (treeViewItem, checked = true) => {
    treeViewItem.checkProps.checked = checked;
    if (treeViewItem.children) {
      treeViewItem.children.forEach(item => {
        if (!item.checkProps.disabled) {
          item.checkProps.checked = checked;
        }
      });
    }
    selectedColumns.forEach(category => {
      category.children.forEach(column => {
        if (treeViewItem.key === column.key && !column.checkProps.disabled) {
          column.checkProps.checked = checked;
        }
        if (treeViewItem.children) {
          treeViewItem.children.forEach(item => {
            if (item.key === column.key && !column.checkProps.disabled) {
              column.checkProps.checked = checked;
            }
          });
        }
      });
    });
  };

  const onCheck = (evt, treeViewItem) => {
    const { checked } = evt.target;
    const checkedItemTree = selectedColumns
      .map(column => Object.assign({}, column))
      .filter(item => filterItems(item, treeViewItem));
    const flatCheckedItems = flattenTree(checkedItemTree);

    if (checked) {
      updateCheckBox(treeViewItem);
      setSelectedColumns(
        selectedColumns
          .concat(
            flatCheckedItems.filter(
              item => !selectedColumns.some(i => i.key === item.key)
            )
          )
          .filter(item => item.children)
      );
    } else {
      updateCheckBox(treeViewItem, false);
      setSelectedColumns(
        selectedColumns.filter(item =>
          flatCheckedItems.some(i => i.key === item.key)
        )
      );
    }
    selectedColumns.map(category => areDescendantsChecked(category));
  };

  const isChecked = dataItem => dataItem.checkProps.checked;
  const areDescendantsChecked = dataItem => {
    if (dataItem.children) {
      if (dataItem.children.every(child => isChecked(child))) {
        dataItem.checkProps.checked = true;
      } else if (dataItem.children.some(child => isChecked(child))) {
        dataItem.checkProps.checked = null;
      } else {
        dataItem.checkProps.checked = false;
      }
    }
  };

  return (
    <div className="pf-c-select-input">
      <div className="pf-c-input-group" id="column-selector">
        <Button
          id="btn-select-columns"
          variant="link"
          icon={<ColumnsIcon />}
          iconPosition="left"
          className="columns-selector"
          onClick={() => toggleModal()}
          title={__('Manage columns')}
        >
          <span className="columns-selector-text">{__('Manage columns')}</span>
        </Button>
        <Modal
          variant={ModalVariant.small}
          title={__('Manage columns')}
          isOpen={isModalOpen}
          onClose={toggleModal}
          tabIndex={0}
          description={__('Select columns to display in the table.')}
          position="top"
          actions={[
            <Button
              key="save"
              variant="primary"
              onClick={() => updateTablePreference()}
            >
              {__('Save')}
            </Button>,
            <Button key="cancel" variant="secondary" onClick={toggleModal}>
              {__('Cancel')}
            </Button>,
          ]}
        >
          <TreeView data={selectedColumns} onCheck={onCheck} hasChecks />
        </Modal>
      </div>
    </div>
  );
};

ColumnSelector.propTypes = {
  data: PropTypes.shape({
    url: PropTypes.string,
    controller: PropTypes.string,
    categories: PropTypes.arrayOf(PropTypes.object),
    hasPreference: PropTypes.bool,
  }),
};

ColumnSelector.defaultProps = {
  data: {
    url: '',
    controller: '',
    categories: [],
    hasPreference: false,
  },
};

export default ColumnSelector;
