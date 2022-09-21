// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/StructureEventExtensions.sol";
import "../general/InternalCallGuard.sol";

contract StructureFacet is Game, InternalCallGuard {
    using StructureEventExtensions for StructureEvent;

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    // --------------------------------------------------------------
    // Public Functions
    // --------------------------------------------------------------

    function buildStructure(uint256 eventId) public onlyInternalCall {
        StructureEvent storage ev = s.structureEvents[eventId];
        ev.build(s);
    }

    function produceStructure(uint256 eventId) public onlyInternalCall {
        StructureEvent storage ev = s.structureEvents[eventId];
        ev.produce(s);
    }

    function dismantleStructure(uint256 eventId) public onlyInternalCall {
        StructureEvent storage ev = s.structureEvents[eventId];
        ev.dismantle(s);
    }

    function burnStructure(uint256 eventId) public onlyInternalCall {
        StructureEvent storage ev = s.structureEvents[eventId];
        ev.burn(s);
    }
}
