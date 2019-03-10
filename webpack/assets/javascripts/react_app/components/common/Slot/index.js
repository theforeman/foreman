import { connect } from 'react-redux';
import { selectRegisteredFills } from './SlotSelectors';
import Slot from './Slot';

// map state to props
const mapStateToProps = (state, ownProps) => ({
  fills: selectRegisteredFills(state, ownProps.id),
});

// export connected component
export default connect(mapStateToProps)(Slot);
