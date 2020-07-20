import React from 'react';

import Pagination from './PaginationWrapper';

const mocks = [
  { id: 1, name: 'Hammer' },
  { id: 2, name: 'Shovel' },
  { id: 3, name: 'Spade' },
  { id: 4, name: 'Pick' },
  { id: 5, name: 'Helmet' },
  { id: 6, name: 'Crane' },
  { id: 7, name: 'Wreckingball' },
  { id: 8, name: 'Truck' },
  { id: 9, name: 'Planks' },
  { id: 10, name: 'Nails' },
  { id: 11, name: 'Nailgun' },
  { id: 12, name: 'Gluegun' },
  { id: 13, name: 'Bricks' },
  { id: 14, name: 'Sand' },
  { id: 15, name: 'Gloves' },
  { id: 16, name: 'Tiles' },
  { id: 17, name: 'Marble' },
  { id: 18, name: 'Sandstone' },
  { id: 19, name: 'Paint' },
  { id: 20, name: 'Brush' },
  { id: 21, name: 'Pipes' },
];

const initPagination = {
  page: 1,
  perPage: 20,
  perPageOptions: [5, 10, 15, 20, 25],
};

const initItems = mocks.slice(0, 20);

class MockPagination extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      pagination: initPagination,
      items: initItems,
    };
  }

  onPaginationChange(newPagination) {
    const offset = (newPagination.page - 1) * newPagination.perPage;
    this.setState({
      items: mocks.slice(offset, offset + newPagination.perPage),
      pagination: Object.assign(this.state.pagination, newPagination),
    });
  }

  render() {
    return (
      <div>
        <ul>{this.state.items.map(renderItem)}</ul>
        <Pagination
          viewType="list"
          itemCount={mocks.length}
          pagination={this.state.pagination}
          onChange={changes => this.onPaginationChange(changes)}
        />
      </div>
    );
  }
}

const renderItem = item => <li key={item.id}>{item.name}</li>;

export default MockPagination;
