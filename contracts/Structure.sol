// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Province.sol";
import "./Roles.sol";
import "./ResourceFactor.sol";
import "./Interfaces.sol";


contract Structure is Initializable, Roles, IStructure {

    IProvince public override province;

    ResourceFactor internal costFactor;

    uint256 public override availableAmount;
    uint256 public override totalAmount;

    modifier onlyRole(bytes32 role) {
        require(province.hasRole(role, msg.sender),"Access denied");
        _;
    }
    

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(province.hasRole(role1, msg.sender) || province.hasRole(role2, msg.sender),"Access denied");
        _;
    }

        /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(IProvince _province) initializer public virtual {
        province = _province;
        _init();
    }

    function _init() internal virtual 
    {
    }


    function typeId() public pure override virtual returns(uint256)
    {
        return 0;
    }

    function constuctionCost() public view override returns(ResourceFactor memory)
    {
        return costFactor;
    }

    function setAvailableAmount(uint256 _availableAmount) public override onlyRoles(PROVINCE_ROLE,EVENT_ROLE) {
        availableAmount = _availableAmount;
    }

    function setTotalAmount(uint256 _amount) public override onlyRoles(PROVINCE_ROLE,EVENT_ROLE) {
        totalAmount += _amount;
    }


    function getSvg() public view virtual returns (string memory) {
        return string(abi.encodePacked(""));
    }    

}