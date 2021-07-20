import { ApolloClient, ApolloLink, InMemoryCache, from } from '@apollo/client';
import { BatchHttpLink } from '@apollo/client/link/batch-http';

const batchLink = new BatchHttpLink({ uri: '/api/graphql' });

const authLink = new ApolloLink((operation, forward) => {
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
  link: from([authLink, batchLink]),
  cache: new InMemoryCache(),
});

export default client;
