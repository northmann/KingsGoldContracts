// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";
import "./LibMeta.sol";

library LibAppStorageExtensions {

    function getUser(AppStorage storage self) internal view returns (User storage user) {
        user = self.users[LibMeta.msgSender()];
    }


    function createProvince(AppStorage storage self, uint _id, string memory _name) internal {
        require(self.provinces[_id].id == 0, "Province already exists");

        Province memory province = self.defaultProvince;
        province.id = _id;
        province.name = _name;
        province.owner = msg.sender;

        self.provinces[_id] = province;
        self.provinceList.push(_id);
        self.users[msg.sender].provinces.push(_id);
    }

}