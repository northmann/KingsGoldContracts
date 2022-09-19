// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";
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

    function addReward(Province storage self, ResourceFactor memory _reward) internal {
        AppStorage storage s = LibAppStorage.appStorage();

        User storage owner = s.getUser(self.owner); // Get the owner of the province
        require(owner.alliance != address(0), "No alliance");

        User storage alliance = s.getUser(owner.alliance); // Get the alliance of the owner

        // Add a part of the reward to the king of the alliance
        ResourceFactor memory alliancePart = _reward.getRewardPart(alliance.allianceFee);
        mintResources(owner.alliance, alliancePart);


        ResourceFactor memory restPart = _reward.getRestReward(alliancePart);


        if(self.vassalExist()) {
            uint256 vassalFee = self.vassalFee > 0 ? self.vassalFee : owner.vassalFee; // Use the province vassal fee if exist otherwise use the owner vassal fee

            ResourceFactor memory ownerPart = restPart.getRewardPart(vassalFee);
            mintResources(self.owner, ownerPart);

            // Whatever is left is for the vassal
            ResourceFactor memory vassalPart = restPart.getRestReward(ownerPart); 
            mintResources(self.vassal, vassalPart);

        } else {
            // There is no vassal so the rest is for the owner
            mintResources(self.owner, restPart);
        }
    }

    function mintResources(address _target, ResourceFactor memory _reward) internal {
        AppStorage storage s = LibAppStorage.appStorage();

        if(_reward.food > 0)
            s.baseSettings.food.mint(_target, _reward.food);

        if(_reward.wood > 0)
            s.baseSettings.wood.mint(_target, _reward.wood);

        if(_reward.rock > 0)
            s.baseSettings.rock.mint(_target, _reward.rock);

        if(_reward.iron > 0)
            s.baseSettings.iron.mint(_target, _reward.iron);
    }

}