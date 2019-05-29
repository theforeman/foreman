import React from 'react';
import gql from 'graphql-tag';

import { withGraphQLData } from '../../common/graphql';

const GET_MODELS = gql`
  {
    models {
      nodes {
        id
        name
      }
    }
  }
`;

const GET_ARCHITECTUES = gql`
  {
    architectures {
      nodes {
        id
        name
      }
    }
  }
`;

const Models = withGraphQLData(
  ({ graphqlData }) => (
    <div>
      {graphqlData.models.nodes.map(n => (
        <span key={n.id}>{n.name}</span>
      ))}
    </div>
  ),
  GET_MODELS
);

const Architectures = withGraphQLData(
  ({ graphqlData }) => (
    <div>
      {graphqlData.architectures.nodes.map(n => (
        <span key={n.id}>{n.name}</span>
      ))}
    </div>
  ),
  GET_ARCHITECTUES
);

export default props => (
  <React.Fragment>
    <Models />
    <Architectures />
  </React.Fragment>
);
