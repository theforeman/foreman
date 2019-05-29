import React from 'react';
// import ApolloClient from 'apollo-boost';
import { ApolloClient } from 'apollo-client';
import { BatchHttpLink } from 'apollo-link-batch-http';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { ApolloLink, concat } from 'apollo-link';
import { ApolloProvider, Query } from 'react-apollo';

const httpLink = new BatchHttpLink({ uri: '/api/graphql' });
const authMiddleware = new ApolloLink((operation, forward) => {
  operation.setContext({
    headers: {
      'X-CSRF-Token': document
        .querySelector('meta[name=csrf-token]')
        .getAttribute('content'),
    },
  });
  return forward(operation);
});

const client = new ApolloClient({
  link: concat(authMiddleware, httpLink),
  cache: new InMemoryCache(),
});

const graphQLWrapperFactory = () => WrappedComponent => props => (
  <ApolloProvider client={client}>
    <WrappedComponent {...props} />
  </ApolloProvider>
);

const withGraphQLData = (Component, query) => props => (
  <Query query={query}>
    {({ loading, error, data }) => {
      if (loading) return 'Loading...';
      if (error) return `Error! ${error.message}`;
      return <Component {...props} graphqlData={data} />;
    }}
  </Query>
);

export { client, graphQLWrapperFactory, withGraphQLData };
