export const arrangeItemsBySelectedIDs = (items, selectedIDs) => {
  const selectedList = [];
  const unselectedlist = [];
  items.forEach(item => {
    const { title: label, id: value } = item.operatingsystem;
    const selectedIDIndex = selectedIDs.indexOf(value);
    const option = { label, value };
    const whichlist = selectedIDIndex !== -1 ? selectedList : unselectedlist;
    whichlist.push(option);
  });

  return { selectedList, unselectedlist };
};
