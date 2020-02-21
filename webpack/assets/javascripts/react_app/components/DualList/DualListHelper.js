export const arrangeItemsBySelectedIDs = (items, selectedIDs) => {
  const selectedList = [];
  const unselectedlist = [];
  items.forEach(item => {
    const selectedIDIndex = selectedIDs.indexOf(item.value);
    const whichlist = selectedIDIndex !== -1 ? selectedList : unselectedlist;
    whichlist.push(item);
  });
  return { selectedList, unselectedlist };
};
