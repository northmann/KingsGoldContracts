// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./AppStorage.sol";
import "./AppStorageExtensions.sol";
import "./ResourceFactorExtensions.sol";

library ProvinceExtensions {
    using AppStorageExtensions for AppStorage;
    using ProvinceExtensions for Province;
    using ResourceFactorExtensions for ResourceFactor;

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function vassalExist(Province storage self) internal view returns (bool) {
        return self.vassal != address(0) && self.vassal != self.owner;
    }

    // --------------------------------------------------------------
    // State Functions
    // --------------------------------------------------------------

    function addReward(Province storage self, ResourceFactor memory _reward, bool taxed, AppStorage storage s) internal {

        // Add population reward to the province
        if (_reward.manPower > 0) {
            self.populationAvailable = self.populationAvailable + _reward.manPower;
            self.populationTotal = self.populationTotal + _reward.manPower;
        }

        User storage owner = s.getUser(self.owner); // Get the owner of the province
        //require(owner.alliance != address(0), "No alliance");

        ResourceFactor memory restPart = _reward;

        // If owner has an alliance, add the reward to the alliance if taxed is true
        if (owner.alliance != address(0) && taxed) {
            User storage alliance = s.getUser(owner.alliance); // Get the alliance of the owner

            // Add a part of the reward to the king of the alliance
            ResourceFactor memory alliancePart = _reward.fee(alliance.allianceFee);
            mintResources(owner.alliance, alliancePart, s);

            restPart = _reward.sub(alliancePart);
        }

        if (self.vassalExist()) {
            uint256 vassalFee = self.vassalFee > 0 ? self.vassalFee : owner.vassalFee; // Use the province vassal fee if exist otherwise use the owner vassal fee
            vassalFee = taxed ? vassalFee : 0; // If taxed is false then the vassal fee is 0

            ResourceFactor memory ownerFee = restPart.fee(vassalFee);
            mintResources(self.owner, ownerFee, s);

            // Whatever is left is for the vassal
            ResourceFactor memory vassalPart = restPart.sub(ownerFee);
            mintResources(self.vassal, vassalPart, s);
        } else {
            // There is no vassal so the rest is for the owner
            mintResources(self.owner, restPart, s);
        }
    }

    function mintResources(address _target, ResourceFactor memory _reward, AppStorage storage s) internal {

        if (_reward.food > 0) s.baseSettings.food.mint(_target, _reward.food);

        if (_reward.wood > 0) s.baseSettings.wood.mint(_target, _reward.wood);

        if (_reward.rock > 0) s.baseSettings.rock.mint(_target, _reward.rock);

        if (_reward.iron > 0) s.baseSettings.iron.mint(_target, _reward.iron);
    }
}
