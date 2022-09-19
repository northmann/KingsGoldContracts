// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";


/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        string functionName;
        string facetName;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;

        mapping(string => address) facetNames;

        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        DiamondStorage storage ds = diamondStorage();


        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {

            IDiamondCut.FacetCut memory facetCut = _diamondCut[facetIndex];
            
            address oldFacetAddress = ds.facetNames[facetCut.facetName];
            if(oldFacetAddress != address(0)) {
                removeFacet(oldFacetAddress); // Clear out old contract
            }

            addFacet(ds, facetCut);

        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    // Remove a facet
    // This allows us to replace a facet with a new facet easily without knowing about the old facet functions
    function removeFacet(address _facetAddress) internal {
        if(_facetAddress == address(0)) return;
        
        DiamondStorage storage ds = diamondStorage();

        FacetFunctionSelectors storage facetFunctionSelectors = ds.facetFunctionSelectors[_facetAddress];
        if(facetFunctionSelectors.functionSelectors.length == 0) return; // No selectors found, so no facet to remove

        uint256 facetAddressPosition = facetFunctionSelectors.facetAddressPosition;

        uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;

        address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];

        ds.facetAddresses[facetAddressPosition] = lastFacetAddress;

        ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = facetAddressPosition;

        ds.facetAddresses.pop();

        for (uint256 selectorIndex; selectorIndex < facetFunctionSelectors.functionSelectors.length; selectorIndex++) {
            delete ds.selectorToFacetAndPosition[facetFunctionSelectors.functionSelectors[selectorIndex]];
        }

        delete ds.facetFunctionSelectors[_facetAddress];

        console.log("Removed facet: %s", _facetAddress);
    }

    function removeFacetAddress(DiamondStorage storage ds, address _facetAddress) internal {
        // replace facet address with last facet address and delete last facet address
        uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
        uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        if (facetAddressPosition != lastFacetAddressPosition) {
            address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
            ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
            ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = facetAddressPosition;
        }
        ds.facetAddresses.pop();
        delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;

        console.log("removeFacetAddress: facet address: %s", _facetAddress);
    }


    function addFacet(DiamondStorage storage ds, IDiamondCut.FacetCut memory facetCut) internal {
        console.log("addFacet: %s", facetCut.facetName);

        // A facet may be added with no selectors. This is useful if the facet is not functional.
        //enforceHasContractCode(facetCut.facetAddress, "LibDiamondCut: New facet has no code");

        ds.facetFunctionSelectors[facetCut.facetAddress].facetAddressPosition = ds.facetAddresses.length;
        ds.facetAddresses.push(facetCut.facetAddress);
        
        // Add the address of the Facet
        ds.facetNames[facetCut.facetName] = facetCut.facetAddress;

        addFunctions(ds, facetCut);

    }   

    function addFunctions(DiamondStorage storage ds, IDiamondCut.FacetCut memory facetCut) internal {

        require(facetCut.facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");

        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[facetCut.facetAddress].functionSelectors.length);

        for (uint256 selectorIndex; selectorIndex < facetCut.functionSignatures.length; selectorIndex++) {
            string memory functionName = facetCut.functionSignatures[selectorIndex];
            bytes4 selector = bytes4(keccak256(bytes(functionName)));

            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");

            addFunction(ds, selector, selectorPosition, facetCut.facetAddress, functionName, facetCut.facetName);

            selectorPosition++;
        }

        console.log("Added %s functions to facet: %s", facetCut.functionSignatures.length, facetCut.facetName);
    }
 


    function addFunction(DiamondStorage storage ds, bytes4 _selector, uint96 _selectorPosition, address _facetAddress, string memory _functionName, string memory _facetName) internal {
        ds.selectorToFacetAndPosition[_selector].functionSelectorPosition = _selectorPosition;
        ds.selectorToFacetAndPosition[_selector].functionName = _functionName;
        ds.selectorToFacetAndPosition[_selector].facetName = _facetName;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(_selector);
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    // function removeFunction(DiamondStorage storage ds, address _facetAddress, bytes4 _selector) internal {        
    //     require(_facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
    //     // an immutable function is a function defined directly in a diamond
    //     require(_facetAddress != address(this), "LibDiamondCut: Can't remove immutable function");
    //     // replace selector with last selector, then delete last selector
    //     uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
    //     uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
    //     // if not the same then replace _selector with lastSelector
    //     if (selectorPosition != lastSelectorPosition) {
    //         bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
    //         ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
    //         ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint96(selectorPosition);
    //     }
    //     // delete the last selector
    //     ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
    //     delete ds.selectorToFacetAndPosition[_selector];

    //     // if no more selectors for facet address then delete the facet address
    //     if (lastSelectorPosition == 0) {
    //         removeFacetAddress(ds, _facetAddress);
    //     }
    // }



    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}
