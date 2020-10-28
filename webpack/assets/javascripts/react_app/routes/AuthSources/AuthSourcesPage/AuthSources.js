import React, { Component } from 'react';
// import PageLayout from '../../common/PageLayout/PageLayout';
import AuthSourceTable from './Components/Table';
// import AuthSourceCard from './Components/Card';
// import AuthSourceEmptyState from './Components/EmptyState';

class AuthSources extends Component {
  componentDidMount() {
    this.props.fetchTableData();
  }

  render() {
    const cells = ['Name', 'Server', 'Automatically', 'LDAPS', 'Actions'];
    const rows = this.props.results.map(
      ({ host, tls, name, onthefly_register }) => ({
        cells: [name, host, onthefly_register.toString(), tls.toString()],
      })
    );
    const actions = [
      {
        title: 'Delete',
        onClick: (event, rowId, rowData, extra) =>
          console.log('Tryign to delete row: ', rowId),
      },
    ];
    return <AuthSourceTable cells={cells} rows={rows} actions={actions} />;
  }
}

export default AuthSources;
