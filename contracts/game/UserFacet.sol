// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";

contract UserFacet is Game
{

    constructor() {
    }


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    
    function getUser() public view returns (User memory user) {
        user = s.users[msg.sender];
    }


    // --------------------------------------------------------------
    // External Functions
    // --------------------------------------------------------------

    function setKingdom() external {
        User storage user = s.users[msg.sender];
        if(user.kingdom == address(0)) {
            user.kingdom = msg.sender;
        }
    }

    error UserNotApprovedToJoinAlliance(address _alliance);

    function allianceApprove(address _target) external {
        require(_target == address(0), "Target is address(0)");
        s.allianceApprovals[msg.sender][_target] = true;
    }

    function isAllianceApproved(address _alliance) public view returns (bool approved) {
        approved = s.allianceApprovals[_alliance][msg.sender];
    }

    function addAlliance(address _alliance) external {
        User storage user = s.users[msg.sender];
        require(user.alliance == address(0), "User already has an alliance");

        if(s.allianceApprovals[_alliance][msg.sender] == true) {
            
            Ally memory ally = Ally({
                user:msg.sender,
                status: 1
            });
            s.alliances[_alliance].push(ally);

            user.alliance = _alliance;
            user.allianceIndex = s.alliances[_alliance].length; // Offset by 1 to account for 0 index as empty.

        } else {
            revert UserNotApprovedToJoinAlliance(_alliance);
        }
    }

    function removeAlliance(address _alliance) external {
        User storage user = s.users[msg.sender];
        require(user.alliance != address(0), "User does not have an alliance");
        require(user.allianceIndex != 0, "User does not have an alliance index");

        Ally[] storage allies = s.alliances[_alliance];
        require(allies[user.allianceIndex-1].user == msg.sender, "User is not a part the alliance");

        allies[user.allianceIndex-1] = allies[allies.length-1];
        allies.pop();

        user.alliance = address(0);
        user.allianceIndex = 0;
    }

    // /**
    //  * @dev Returns `true` if `account` has been granted `role`.
    //  */
    // function hasRole(bytes32 role, address account) public view override returns (bool) {
    //     return super.hasRole(role, account);
    // }

    // function ensureUserAccount()
    //     public
    //     override
    //     onlyRole(MINTER_ROLE)
    //     returns (IUserAccount)
    // {
    //     UserAccountStorage storage ds = userAccountStorage();


    //     if (ds.users[tx.origin] != address(0)) return IUserAccount(ds.users[tx.origin]); // If user exist, then just return.

    //     BeaconProxy proxy = new BeaconProxy(
    //         userAccountBeacon,
    //         abi.encodeWithSelector(UserAccount(address(0)).initialize.selector)
    //     );
    //     ds.users[tx.origin] = address(proxy);

    //     _grantRole(USER_ROLE, tx.origin);

    //     return IUserAccount(address(proxy));
    // }

    // function grantProvinceRole(IProvince _province) public override onlyRole(MINTER_ROLE) {
    //     _grantRole(PROVINCE_ROLE, address(_province));
    // }

    // function grantSpenderRole(IProvince _province) public override onlyRole(MINTER_ROLE) {
    //     _grantRole(SPENDER_ROLE, address(_province));
    // }

    // function grantTemporaryMinterRole(IProvince _province) public override onlyRole(MINTER_ROLE) {
    //     _grantRole(TEMPORARY_MINTER_ROLE, address(_province));
    // }

    // function revokeTemporaryMinterRole(IProvince _province) public override onlyRole(MINTER_ROLE) {
    //     _revokeRole(TEMPORARY_MINTER_ROLE, address(_province));
    // }

    // // Can only be called by a Province Contract
    // function setEventRole(address _eventContract) public override onlyRole(PROVINCE_ROLE) {
    //     require(ERC165Checker.supportsInterface(_eventContract, type(IEvent).interfaceId), "Not a event contract");

    //     _grantRole(EVENT_ROLE, _eventContract);
    // }

    // function getUserAccount(address _user) external view override returns (IUserAccount) {

    //     UserAccountStorage storage ds = userAccountStorage();
    //     return IUserAccount(ds.users[_user]);
    // }

    //     function provinceCount() public view override returns(uint256)
    // {
    //     return provinces.length();
    // }

    // function addProvince(IProvince _province) public override {
    //     console.log("addProvince - add province: ",  address(_province));
    //     provinces.add(address(_province));
    // }

    // function removeProvince(address _province) public override {
    //     provinces.remove(_province);
    // }

    // function getProvince(uint256 index) public view override returns(address) {
    //     require(index < provinces.length());

    //     return provinces.at(index);
    // }

    // function getProvinces() public view override returns(address[] memory) {
    //     address[] memory result = new address[](provinces.length());
    //     for(uint256 i = 0; i < provinces.length(); i++)
    //         result[i] = provinces.at(i);
    //     return result;
    // }



}
