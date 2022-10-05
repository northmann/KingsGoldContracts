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

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


contract ArmyFacet is Game, GameAccess, InternalCallGuard {
    using AppStorageExtensions for AppStorage;
    using ProvinceExtensions for Province;
    using ArmyExtensions for Army;
    using UIntExtensions for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    event BattleResult(uint256 indexed _attackingArmyId, uint256 indexed _defendingArmyId, Battle battle);


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getArmy(uint256 _armyId) external view returns (Army memory army) {
        require(_armyId > 0, "ArmyFacet_exchangeArmy: Invalid defending army id, cannot be zero");

        army = s.armies[_armyId];
    }

    function getProvinceArmies(uint256 _provinceId) external view returns (Army[] memory armies_) {
        armies_ = _getArmies(s.provinceArmies[_provinceId].values());
    }

    function getDepartureArmies(uint256 _provinceId) external view returns (Army[] memory armies_) {
        armies_ = _getArmies(s.departureArmies[_provinceId].values());
    }

    function getUserArmies(address _user) external view returns (Army[] memory armies_) {
        armies_ = _getArmies(s.userArmies[_user].values());
    }

    function getArmyUnits(uint256 _armyId) external view returns (ArmyUnit[ArmyUnitTypeCount] memory units) {
        require(_armyId > 0, "ArmyFacet_exchangeArmy: Invalid defending army id, cannot be zero");

        for(uint8 i = 0; i < ArmyUnitTypeCount; i++) {
            units[i] = s.armyUnits[_armyId][ArmyUnitType(i)];
        }
    }



    

    // --------------------------------------------------------------
    // Public Functions
    // --------------------------------------------------------------

    function attackArmy(uint256 _attackingArmyId, uint256 _defendingArmyId, uint256 _rounds) public
    {
        require(_defendingArmyId > 0, "ArmyFacet_exchangeArmy: Invalid defending army id, cannot be zero");
        
        Army memory _attackingArmy = s.armies[_attackingArmyId];
        Army memory _defendingArmy = s.armies[_defendingArmyId];

        require(msg.sender == _attackingArmy.owner, "ArmyFacet_exchangeArmy: Not attacking army owner");
        require(_attackingArmy.provinceId == _defendingArmy.provinceId, "ArmyFacet_exchangeArmy: Attacking and defending army is not in the same province");
        require(_attackingArmy.state == ArmyState.Idle, "ArmyFacet_exchangeArmy: Attacking Army not idle");
        require(_defendingArmy.state != ArmyState.Moving, "ArmyFacet_exchangeArmy: Defending Army not idle");

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
        //Army storage sharesArmy = s.armyShares[sourceArmy.owner][_targetArmyId];

        require(msgSender() == sourceArmy.owner, "ArmyFacet_exchangeArmy: Not source army owner");
        require(sourceArmy.provinceId == targetArmy.provinceId, "ArmyFacet_exchangeArmy: Source and target army is not in the same province");
        require(sourceArmy.state == ArmyState.Idle, "ArmyFacet_exchangeArmy: Source Army not idle");
        require(targetArmy.state == ArmyState.Idle, "ArmyFacet_exchangeArmy: Target Army not idle");

        for (uint256 i = 0; i < _callUnits.length; i++) {
            ArmyUnitType armyUnitTypeId = _callUnits[i].armyUnitTypeId;
           
            ArmyUnit storage sourceUnit = s.armyUnits[sourceArmy.id][armyUnitTypeId];
            ArmyUnit storage sharesUnit = s.armyShareUnits[sourceArmy.owner][targetArmy.id][armyUnitTypeId];
            ArmyUnit storage targetUnit = s.armyUnits[targetArmy.id][armyUnitTypeId];

            _exchangeArmyUnit(sourceUnit, _callUnits[i], sharesUnit, targetUnit);
        }          
        
        uint256 sharesCount = 0;
        for (uint256 i = 0; i < ArmyUnitTypeCount; i++) {
            sharesCount += s.armyShareUnits[sourceArmy.owner][targetArmy.id][ArmyUnitType(i)].shares;
        }

        if(sharesCount > 0) // If the user has shares in target army then add it to the user shares list
            s.userShareArmies[sourceArmy.owner].add(_targetArmyId);
        else // If the user has no shares in target army then remove it from the user shares list
            s.userShareArmies[sourceArmy.owner].remove(_targetArmyId);
    }


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

    function _initBattle(Army memory _attackingArmy, Army memory _defendingArmy, Battle memory battle) internal view {
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
           round.attackDeviation = _getPseudoGaussianDeviation(round.totalAttackHit + ((round.id+1) << 16));
           round.defenceDeviation = _getPseudoGaussianDeviation(round.totalDefenceHit + ((round.id+1) << 8));
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

    
   
   function _getPseudoGaussianDeviation(uint256 _seed) internal view returns(int256 percent_) {
        uint256 r = uint256(keccak256(abi.encodePacked(_seed, block.timestamp)));
        percent_ = ((int256(r.countOnes()) - 128) * 100) / 128;
    }

    function _getArmies(uint256[] memory _armyIds) internal view returns (Army[] memory armies) {
        armies = new Army[](_armyIds.length);
        for (uint256 i = 0; i < _armyIds.length; i++) {
            armies[i] = s.armies[_armyIds[i]];
        }
    }


   

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
        uint256 armyId = s.nextArmyId(); // s.armyCount++; // Army Index starts with 1

        army = s.armies[armyId];
        army.id = armyId;
        army.state = ArmyState.Idle;
        army.owner = _owner;

        army.provinceId = _provinceId;
        army.departureProvinceId = 0;

        s.provinceArmies[_provinceId].add(armyId);

        s.userArmies[_owner].add(armyId);
    }

    function _removeArmy(Army storage army) internal {
        // Remove army from departure province
        _removeDepartureMove(army);
        _removeDestinationMove(army);

        // Remove army from owner
        s.userArmies[army.owner].remove(army.id);

        delete s.armies[army.id]; // Delete army
    }

    function _setDestinationMove(Army storage army, uint256 _destinationId) internal {
        army.provinceId = _destinationId;

        s.provinceArmies[_destinationId].add(army.id);
    }

    function _setDepartureMove(Army storage army) internal {
        _removeDestinationMove(army); // Remove from main list

        army.departureProvinceId = army.provinceId;
        s.departureArmies[army.provinceId].add(army.id);
    }

    function _removeDepartureMove(Army storage army) internal {
        if(army.departureProvinceId == 0) return;

        s.departureArmies[army.departureProvinceId].remove(army.id);

        army.departureProvinceId = 0;
    }

    function _removeDestinationMove(Army storage army) internal {
        // Army arrived at destination and is now idle
        // Remove army from departure province
        s.provinceArmies[army.provinceId].remove(army.id);
    }
}
