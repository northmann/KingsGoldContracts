// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/ProvinceExtensions.sol";
import "../libraries/ArmyExtensions.sol";
import "../libraries/LibRoles.sol";
import "../libraries/Math.sol";
import "../libraries/UIntExtensions.sol";
import "../general/InternalCallGuard.sol";
import "../general/Game.sol";
import "./AccessControlFacet.sol";
import "./GameAccess.sol";

contract ArmyFacet is Game, GameAccess, InternalCallGuard {
    using AppStorageExtensions for AppStorage;
    using ProvinceExtensions for Province;
    using ArmyExtensions for Army;
    using UIntExtensions for uint256;

    event BattleResult(uint256 indexed _attackingArmyId, uint256 indexed _defendingArmyId, Battle battle);


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getArmy(uint256 _armyId) external view returns (Army memory army) {
        army = s.armies[_armyId];
    }

    function getProvinceArmies(uint256 provinceId) external view returns (Army[] memory armies) {
        uint256[] memory armyList = s.provinceArmies[provinceId];

        armies = new Army[](armyList.length);
        for (uint256 i = 0; i < armyList.length; i++) {
            armies[i] = s.armies[armyList[i]];
        }
    }

    // function getArmyUnits(uint256 _armyId) external view returns (ArmyUnit[] memory units) {
    //     Army storage army = s.armies[_armyId];
    //     units = army.units;
    // }

    // --------------------------------------------------------------
    // Public Functions
    // --------------------------------------------------------------


    
    //function battle(uint256 _defendingArmyId, ArmyUnit[] memory _callUnits, uint256 _rounds) public returns(uint256 battleDone) {
    function AttackArmy(uint256 _rounds) public {

        //require(_defendingArmyId > 0, "ArmyFacet_exchangeArmy: Invalid defending army id, cannot be zero");
        
        // Army storage targetArmy = s.armies[_targetArmyId];
        // Army storage sourceArmy = (_sourceArmyId > 0) ? s.armies[_sourceArmyId] : _createArmy(targetArmy.provinceId, msgSender()); // Create army if source army is 0
        // Army storage sharesArmy = s.armyShares[sourceArmy.owner][_targetArmyId];

        //require(msg.sender == sourceArmy.owner, "ArmyFacet_exchangeArmy: Not source army owner");
        //require(sourceArmy.provinceId == targetArmy.provinceId, "ArmyFacet_exchangeArmy: Source and target army is not in the same province");
        //require(sourceArmy.state == ArmyState.Idle, "ArmyFacet_exchangeArmy: Source Army not idle");
        //require(targetArmy.state == ArmyState.Idle, "ArmyFacet_exchangeArmy: Target Army not idle");
        //Army storage targetArmy = s.armies[_targetArmyId];
        //Army storage sourceArmy = s.armies[_sourceArmyId];
        Army storage _attackingArmy = s.armies[0];
        Army storage _defendingArmy = s.armies[1];

        Battle memory battle;

        battle.rounds = new BattleRound[](_rounds);
      
        // Load up in memory ---------
        _initBattle(_attackingArmy, _defendingArmy, battle);

        // Process rounds --------
        for(uint256 r = 0; r < _rounds; r++) {

            // Process hits
            BattleRound memory round = battle.rounds[r];
            round.id = r;

            // Add some random to the battle
            _initRandom(round);

            // Archer attack first strike
            _unitAttack(battle, round, uint8(ArmyUnitType.Archer));
            _addRandomToAttack(round);
            _processCasualties(battle, round);

            // If there are no more unit amount in attack or defence army then stop.
            if(round.totalAttackHit != 0 || round.totalDefenceHit != 0)
                break;

            // The rest
            _unitAttack(battle, round, uint8(ArmyUnitType.Militia));
            _unitAttack(battle, round, uint8(ArmyUnitType.Soldier));
            _unitAttack(battle, round, uint8(ArmyUnitType.Knight));
            _unitAttack(battle, round, uint8(ArmyUnitType.Catapult));

            _addRandomToAttack(round);
            _processCasualties(battle, round);

            // If there are no more unit amount in attack or defence army then stop.
            if(round.totalAttackHit != 0 || round.totalDefenceHit != 0)
                break;
        }


        // Write back to storage
        for(uint8 i = 1; i < ArmyUnitTypeCount; i++) {
            s.armyUnits[_attackingArmy.id][ArmyUnitType(i)] = battle.units[i].attack;
            s.armyUnits[_defendingArmy.id][ArmyUnitType(i)] = battle.units[i].defence;
        } 
               
        emit BattleResult(_attackingArmy.id, _defendingArmy.id, battle);
    }

    function _initBattle(Army storage _attackingArmy, Army storage _defendingArmy, Battle memory battle) internal view {
        battle.defendingState = _defendingArmy.state;

        for(uint8 i = 1; i < ArmyUnitTypeCount; i++) {
            BattleUnit memory unit = battle.units[i];

            unit.armyUnitTypeId = ArmyUnitType(i);
            unit.armyUnitProperties = s.armyUnitTypes[ArmyUnitType(i)];
            unit.attack = s.armyUnits[_attackingArmy.id][ArmyUnitType(i)];
            unit.defence = s.armyUnits[_defendingArmy.id][ArmyUnitType(i)];
        }
    }

    function _initRandom(BattleRound memory round) internal view {
           round.attackDeviation = getPseudoGaussianDeviation(round.totalAttackHit + ((round.id+1) << 16));
           round.defenceDeviation = getPseudoGaussianDeviation(round.totalDefenceHit + ((round.id+1) << 8));
    }
    

    function _unitAttack(Battle memory battle, BattleRound memory round, uint8 i) internal pure {
        BattleHit memory hit = round.hits[i];
        BattleUnit memory unit = battle.units[i];
        hit.armyUnitTypeId = ArmyUnitType(i);

        uint256 attackScore = (battle.defendingState == ArmyState.Garrison) ? unit.armyUnitProperties.seigeAttack : unit.armyUnitProperties.openAttack;
        hit.attackHit = (attackScore * unit.attack.amount) / maxPower;
        round.totalAttackHit += hit.attackHit;
        round.totalAttackUnits += unit.attack.amount;

        uint256 defenceScore = (battle.defendingState == ArmyState.Garrison) ? unit.armyUnitProperties.seigeDefence : unit.armyUnitProperties.openDefence;
        hit.defenceHit = (defenceScore * unit.defence.amount) / maxPower;
        round.totalDefenceHit += hit.defenceHit;
        round.totalDefenceUnits += unit.defence.amount;
    }

    function _addRandomToAttack(BattleRound memory round) internal pure {
        int256 diffAttack = (int256(round.totalAttackHit) * round.attackDeviation) / 100;
        round.totalAttackHit = uint256(int256(round.totalAttackHit) + diffAttack);

        int256 diffDefence = (int256(round.totalAttackHit) * round.attackDeviation) / 100;
        round.totalDefenceHit = uint256(int256(round.totalDefenceHit) + diffDefence);
    }

    function _processCasualties(Battle memory battle, BattleRound memory round) internal pure {

        for(uint8 i = 1; i < ArmyUnitTypeCount; i++) {
            BattleUnit memory unit = battle.units[i];

            if(round.totalAttackHit > 0) {
                if(unit.defence.amount >= round.totalAttackHit) {
                    unit.defence.amount -= round.totalAttackHit;
                    round.totalAttackHit = 0;
                } else {
                    round.totalAttackHit -= unit.defence.amount;
                    unit.defence.amount = 0;
                }
            }

            if(round.totalDefenceHit > 0) {
                if(unit.attack.amount >= round.totalDefenceHit) {
                    unit.attack.amount -= round.totalDefenceHit;
                    round.totalDefenceHit = 0;
                } else {
                    round.totalDefenceHit -= unit.attack.amount;
                    unit.attack.amount = 0;
                }
            }

        }
     }

    
   
   function getPseudoGaussianDeviation(uint256 _seed) public view returns(int256 percent_) {
        uint256 r = uint256(keccak256(abi.encodePacked(_seed, block.timestamp)));
        percent_ = ((int256(r.countOnes()) - 128) * 100) / 128;
    }



    function createArmy(uint256 _provinceId, ArmyUnit[] calldata _units) public requiredRole(LibRoles.MINTER_ROLE) {
        Army storage army = _createArmy(_provinceId, msgSender());
        uint256 armyId = army.id;

        for (uint256 i = 0; i < _units.length; i++) 
            s.armyUnits[armyId][_units[i].armyUnitTypeId] = _units[i];
    }

    function updateArmy(uint256 _armyId, ArmyUnit[] calldata _units) public requiredRole(LibRoles.MINTER_ROLE) {
        Army storage army = s.armies[_armyId];
        uint256 armyId = army.id;

        for (uint256 i = 0; i < _units.length; i++) 
            s.armyUnits[armyId][_units[i].armyUnitTypeId] = _units[i];
    }

    function updateGarrison(uint256 _provinceId, ArmyUnit[] calldata _units) public requiredRole(LibRoles.MINTER_ROLE) {
        Army storage army = _getGarrison(_provinceId);

        uint256 armyId = army.id;

        for (uint256 i = 0; i < _units.length; i++) 
            s.armyUnits[armyId][_units[i].armyUnitTypeId] = _units[i];
    }

    function moveArmy(uint256 _armyId, uint256 _destinationId) public {
        Army storage army = s.armies[_armyId];
        require(msgSender() == army.owner, "ArmyFacet: Not owner");
        require(army.provinceId == _destinationId, "ArmyFacet: Army already moved or moving to that province");

        if (army.state == ArmyState.Moving) {
            if (block.timestamp >= army.endTime) {
                _removeDepartureMove(army);
                _setDepartureMove(army);
                _setDestinationMove(army, _destinationId);
            } else {
                _removeDestinationMove(army);
                _setDestinationMove(army, _destinationId);
            }
        } else {
            // Army other state
            _setDepartureMove(army);
            _setDestinationMove(army, _destinationId);
        }
    }

    // Exchanges army units with another army
    // _callUnits: specifies the units to be added or removed from the army
    // _callUnit.amount > 0: add units to the target army
    // _callUnit.shares > 0: remove units from the target army
    function exchangeArmy(uint256 _sourceArmyId, ArmyUnit[] calldata _callUnits, uint256 _targetArmyId) public {
        require(_targetArmyId > 0, "ArmyFacet_exchangeArmy: Invalid target army id, cannot be zero");
        
        Army storage targetArmy = s.armies[_targetArmyId];
        Army storage sourceArmy = (_sourceArmyId > 0) ? s.armies[_sourceArmyId] : _createArmy(targetArmy.provinceId, msgSender()); // Create army if source army is 0
        Army storage sharesArmy = s.armyShares[sourceArmy.owner][_targetArmyId];

        require(msgSender() == sourceArmy.owner, "ArmyFacet_exchangeArmy: Not source army owner");
        require(sourceArmy.provinceId == targetArmy.provinceId, "ArmyFacet_exchangeArmy: Source and target army is not in the same province");
        require(sourceArmy.state == ArmyState.Idle, "ArmyFacet_exchangeArmy: Source Army not idle");
        require(targetArmy.state == ArmyState.Idle, "ArmyFacet_exchangeArmy: Target Army not idle");

        for (uint256 i = 0; i < _callUnits.length; i++) {
            ArmyUnitType armyUnitTypeId = _callUnits[i].armyUnitTypeId;
           
            ArmyUnit storage sourceUnit = s.armyUnits[sourceArmy.id][armyUnitTypeId];
            ArmyUnit storage sharesUnit = s.armyUnits[sharesArmy.id][armyUnitTypeId];
            ArmyUnit storage targetUnit = s.armyUnits[targetArmy.id][armyUnitTypeId];

            _exchangeArmyUnit(sourceUnit, _callUnits[i], sharesUnit, targetUnit);
        }          
    }

    // Attack another army
    // _callUnits: specifies the units used to attack another army
    // The ordering of the units in the array is important, the first unit in the array is the first unit to be used in the attack
    // and the first unit to be removed from the army as casualties.
    // Battle rules: The attacker throw a dice for each unit in the attack, the defender throw a dice for each unit in the defense.
    // If the attacker has superior numbers, more than 3-1, then half of the defender units are removed without a counter attack. 
     
    // function attackArmy(uint256 _sourceArmyId, uint256 _targetArmyId, ArmyUnit[] calldata _callUnits, uint256 _rounds) public {
    //     require(_sourceArmyId > 0, "ArmyFacet_attackArmy: Invalid source army id, cannot be zero");
    //     require(_targetArmyId > 0, "ArmyFacet_attackArmy: Invalid target army id, cannot be zero");
        
    //     Army storage targetArmy = s.armies[_targetArmyId];
    //     Army storage sourceArmy = s.armies[_sourceArmyId];

    //     require(msgSender() == sourceArmy.owner, "ArmyFacet_attackArmy: Not source army owner");
    //     require(sourceArmy.provinceId == targetArmy.provinceId, "ArmyFacet_attackArmy: Source and target army is not in the same province");
    //     require(sourceArmy.state == ArmyState.Idle, "ArmyFacet_attackArmy: Source Army not idle");
    //     require(targetArmy.state == ArmyState.Idle, "ArmyFacet_attackArmy: Target Army not idle");
    //     require(sourceArmy.owner != targetArmy.owner, "ArmyFacet_attackArmy: Source and target army is owned by the same player");


    //     for(uint256 r = 0; r < _rounds; r++) {
    //         for (uint256 i = 0; i < _callUnits.length; i++) {
    //             ArmyUnit calldata callUnit = _callUnits[i];
    //             ArmyUnitType armyUnitTypeId = callUnit.armyUnitTypeId;
    //             ArmyUnit storage sourceUnit = sourceArmy.getUnit(armyUnitTypeId);

                






    //             ArmyUnit storage targetUnit = targetArmy.getUnit(armyUnitTypeId);



    //             _attackArmyUnit(sourceUnit, _callUnits[i], targetUnit);
    //         }
    //     }
    // }



    // --------------------------------------------------------------
    // Internal Call Functions
    // --------------------------------------------------------------

    function produceSoldier(uint256 eventId) public onlyInternalCall {
        _produceUnit(eventId, ArmyUnitType.Soldier);
    }

    function produceArcher(uint256 eventId) public onlyInternalCall {
        _produceUnit(eventId, ArmyUnitType.Archer);
    }

    function produceKnight(uint256 eventId) public onlyInternalCall {
        _produceUnit(eventId, ArmyUnitType.Knight);
    }

    function produceCatapult(uint256 eventId) public onlyInternalCall {
        _produceUnit(eventId, ArmyUnitType.Catapult);
    }

    // --------------------------------------------------------------
    // Private Functions
    // --------------------------------------------------------------

    function _exchangeArmyUnit(ArmyUnit storage _sourceUnit, ArmyUnit calldata _callUnit, ArmyUnit storage _targetUnit, ArmyUnit storage _sharesUnit) internal {
        
            uint256 sourceAmount = _callUnit.amount;
            uint256 shares = 0;
            
            if(sourceAmount > 0) {
                require(_sourceUnit.amount >= _callUnit.amount, "ArmyFacet_exchangeArmyUnit: Not enough unit amount in source army");
                // Add units to target army
                _targetUnit.amount += sourceAmount; // Add units before calculating shares

                if(_targetUnit.shares == 0)
                    shares = Math.sqrt(sourceAmount);
                else {
                    shares = (sourceAmount * _targetUnit.shares) / _targetUnit.amount;
                }

                _sourceUnit.amount -= sourceAmount;

                _sharesUnit.shares += shares; // The users shares of the unit
                _targetUnit.shares += shares; // Total shares of the unit
            }
            else {
                // Remove units from target army
                require(_targetUnit.shares > 0, "ArmyFacet_exchangeArmyUnit: There is no unit shares in target army");
                require(_sharesUnit.shares >= _callUnit.shares, "ArmyFacet_exchangeArmyUnit: Not enough unit shares in shares army");
                require(_targetUnit.shares >= _callUnit.shares, "ArmyFacet_exchangeArmyUnit: Not enough unit shares in target army");


                uint256 amount = (_callUnit.shares * _targetUnit.amount) / _targetUnit.shares;

                require(amount <= _targetUnit.amount, "ArmyFacet: Not enough amount in target army");

                _targetUnit.amount -= amount; // Remove units after calculating amount
                _sourceUnit.amount += amount;

                _targetUnit.shares -= _callUnit.shares;
                _sharesUnit.shares -= _callUnit.shares;
            }
    }


    function _produceUnit(uint256 eventId, ArmyUnitType typeId) internal {
        StructureEvent storage ev = s.structureEvents[eventId];

        Army storage garrison = _getGarrison(ev.provinceId);

        ArmyUnit storage unit = s.armyUnits[garrison.id][typeId];

        unit.amount += ev.calculatedReward.amount;
    }

    function _getGarrison(uint256 provinceId) internal returns (Army storage garrison) {
        Province storage province = s.provinces[provinceId];
        if (province.garrisonId == 0) {
            garrison = _createArmy(provinceId, msgSender());
        } else garrison = s.armies[province.garrisonId];
    }

    function _createArmy(uint256 _provinceId, address _owner) internal returns (Army storage army) {
        s.armyCount++; // Army Index starts with 1

        army = s.armies[s.armyCount];
        army.id = s.armyCount;
        army.state = ArmyState.Idle;
        army.owner = _owner;

        army.provinceId = _provinceId;
        army.departureProvinceId = 0;

        army.provinceArmyIndex = s.provinceArmies[_provinceId].length;
        s.provinceArmies[_provinceId].push(s.armyCount);

        army.ownerArmyIndex = s.userArmies[_owner].length;
        s.userArmies[_owner].push(s.armyCount);
    }

    function _removeArmy(Army storage army) internal {
        // Remove army from departure province
        _removeDepartureMove(army);
        _removeDestinationMove(army);

        // Remove army from owner
        _removeArmyFromOwner(army);

        delete s.armies[army.id]; // Delete army
    }

    function _setDestinationMove(Army storage army, uint256 _destinationId) internal {
        army.provinceId = _destinationId;
        army.provinceArmyIndex = s.provinceArmies[_destinationId].length;
        s.provinceArmies[_destinationId].push(army.id);
    }

    function _setDepartureMove(Army storage army) internal {
        _removeDestinationMove(army); // Remove from main list

        army.departureArmyIndex = s.departureArmies[army.provinceId].length;
        army.departureProvinceId = army.provinceId;
        s.departureArmies[army.provinceId].push(army.id);
    }

    function _removeDepartureMove(Army storage army) internal {
        if(army.departureProvinceId == 0) return;

        uint256 lastArmyId = _removeArmyFromArray(s.departureArmies[army.departureProvinceId], army.departureArmyIndex);
        s.armies[lastArmyId].departureArmyIndex = army.departureArmyIndex;
        army.departureProvinceId = 0;
    }

    function _removeDestinationMove(Army storage army) internal {
        // Army arrived at destination and is now idle
        // Remove army from departure province
        uint256 lastArmyId = _removeArmyFromArray(s.provinceArmies[army.provinceId], army.provinceArmyIndex);
        s.armies[lastArmyId].provinceArmyIndex = army.provinceArmyIndex;
    }

    function _removeArmyFromOwner(Army storage army) internal {
        uint256 lastArmyId = _removeArmyFromArray(s.userArmies[army.owner], army.ownerArmyIndex);
        s.armies[lastArmyId].ownerArmyIndex = army.ownerArmyIndex;
    }

    function _removeArmyFromArray(uint256[] storage armyArray, uint256 armyIndex) internal returns (uint256) {
        if (armyArray.length > 0) {
            uint256 lastArmyId = armyArray[armyArray.length - 1];
            armyArray[armyIndex] = lastArmyId;
            armyArray.pop();
            return lastArmyId;
        }
        return 0;
    }


}
