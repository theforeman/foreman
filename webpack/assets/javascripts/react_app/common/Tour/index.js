import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import { wrapComponentWithTour } from './Tour';
import {
  selectActiveTour,
  selectIsRunning,
  selectIsAlreadySeen,
  selectLoadingState,
} from './TourSelectors';
import * as actions from './TourActions';
import reducer from './TourReducer';

export { default as BasicTour } from './BasicTour';

const withTour = (WrappedComponent, steps, id) => {
  const tour = wrapComponentWithTour(WrappedComponent, steps, id);

  const mapStateToProps = state => ({
    alreadySeen: selectIsAlreadySeen(state, id),
    running: selectIsRunning(state, id),
    activeTour: selectActiveTour(state),
    isLoading: selectLoadingState(state),
  });
  const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);
  return connect(
    mapStateToProps,
    mapDispatchToProps
  )(tour);
};

// export reducers
export const reducers = { tours: reducer };

export default withTour;
