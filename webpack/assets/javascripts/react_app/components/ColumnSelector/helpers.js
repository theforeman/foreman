const getCheckedStateForCategory = (category = { children: [] }) => {
  // return true if all children are checked
  // return null if some children are checked
  // return false if no children are checked
  const checked = category.children.map(child => child.checkProps?.checked);
  if (checked.every(Boolean)) return true;
  if (checked.some(Boolean)) return null;
  return false;
};

export const categoriesFromFrontendColumnData = ({
  registeredColumns,
  userId,
  controller = 'hosts',
  userColumns = ['name'],
  hasPreference = false,
}) => {
  // need to build an object like
  // {
  //     "url": "/api/users/4/table_preferences",
  //     "controller": "hosts",
  //     "categories": [
  //         {
  //             "name": "General",
  //             "key": "general",
  //             "defaultExpanded": true,
  //             "checkProps": {
  //                 "checked": true
  //             },
  //             "children": [
  //                 {
  //                     "name": "Power",
  //                     "key": "power_status",
  //                     "checkProps": {
  //                         "disabled": null,
  //                         "checked": true
  //                     }
  //                 },
  //             ]
  //         },
  //     ],
  //     "hasPreference": true
  // }

  const result = {
    url: userId ? `/api/users/${userId}/table_preferences` : null,
    controller,
    hasPreference,
  };

  const categories = [];
  Object.keys(registeredColumns).forEach(column => {
    const {
      categoryName,
      categoryKey,
      tableName,
      columnName,
      title,
      isRequired,
    } = registeredColumns[column];
    if (tableName !== controller) return;
    const category = categories.find(cat => cat.key === categoryKey);
    if (!category) {
      categories.push({
        name: categoryName,
        key: categoryKey,
        defaultExpanded: true,
        checkProps: {
          checked: false,
        },
        children: [],
      });
    }
    const categoryIndex = categories.findIndex(cat => cat.key === categoryKey);
    categories[categoryIndex].children.push({
      name: title,
      key: columnName,
      checkProps: {
        checked: isRequired || userColumns.includes(columnName),
        disabled: isRequired ?? null,
      },
    });
  });
  categories.forEach(category => {
    category.checkProps.checked = getCheckedStateForCategory(category);
  });
  result.categories = categories;
  return result;
};
