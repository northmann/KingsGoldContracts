// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

//import "./Beacon.sol";
import "./GenericNFT.sol";
//import "./Province.sol";
//import "./Interfaces.sol";

contract ProvinceNFT is Initializable, GenericNFT {
    //using EnumerableMap for EnumerableMap.AddressToUintMap;
    //using Strings for uint256;

    //IContinent public override continent;
    //address public beaconAddress;

    //mapping(uint256 => IProvince) public provinces;
    //EnumerableMap.AddressToUintMap internal lookup;

    //mapping(uint256 => string) private svgResources; // the svg for the resource!

    //string constant SVGHEADER = "<svg width='350px' height='350px' viewBox='0 0 24 24' fill='none' xmlns='http://www.w3.org/2000/svg'>";
    //string constant SVGFOOTER = "</svg>";

    function initialize(address _game) initializer override public {
        super.initialize(_game); // Call parent GenericNFT
        __ERC721_init("KingsGold Provinces", "KSGP");
    }

    // function setProvinceBeacon(address _template) external override onlyRole(UPGRADER_ROLE) {
    //     beaconAddress = _template;
    // }
    
    // function mintProvince(string memory _name, address _owner) public override onlyGame returns(uint256, IProvince) {
        
    //     // console.log("mintProvince: msg.sender: ", msg.sender);
    //     // console.log("mintProvince: msg.origin: ", tx.origin);
    //     // console.log("mintProvince: beaconAddress: ", beaconAddress);
    //     // console.log("Owner: beaconAddress: ", _owner);
    //     // console.log("Continent: continent: ", address(continent));

    //     uint256 tokenId = safeMint(_owner); 
       
    //     BeaconProxy proxy = new BeaconProxy(beaconAddress   ,abi.encodeWithSelector(Province(address(0)).initialize.selector    , _name, _owner, continent));


    //     console.log("mintProvince: adding province to provinces list");
    //     provinces[tokenId] = IProvince(address(proxy));

    //     console.log("mintProvince: setting province to lookup list");
    //     lookup.set(address(proxy), tokenId);

    //     return (tokenId, IProvince(address(proxy)));
    // }
    
    // function getTokenId(address _provinceAddress) external view override returns(uint256)
    // {
    //     return lookup.tryGet(_provinceAddress);
    // }

    // function contains(address _provinceAddress) external view override returns(bool)
    // {
    //     return lookup.contains(_provinceAddress);
    // }

    // function setContinent(IContinent _continent) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    //     continent = _continent;
    // }

    // function addSvgResouces(uint256 id, string memory svg) external override onlyRole(DEFAULT_ADMIN_ROLE)
    // {
    //     svgResources[id] = svg;
    // }


    // function getSvg() private pure returns (string memory) {
    //     //uint32 wood = province.forest();
    //     //string memory image = svgResources[wood];
    //     string memory svg = string(abi.encodePacked(
    //         SVGHEADER, 
    //         "<path d='M11.55 18.46C11.3516 18.4577 11.1617 18.3789 11.02 18.24L5.32001 12.53C5.19492 12.3935 5.12553 12.2151 5.12553 12.03C5.12553 11.8449 5.19492 11.6665 5.32001 11.53L13.71 3C13.8505 2.85931 14.0412 2.78017 14.24 2.78H19.99C20.1863 2.78 20.3745 2.85796 20.5133 2.99674C20.652 3.13552 20.73 3.32374 20.73 3.52L20.8 9.2C20.8003 9.40188 20.7213 9.5958 20.58 9.74L12.07 18.25C11.9282 18.3812 11.7432 18.4559 11.55 18.46ZM6.90001 12L11.55 16.64L19.3 8.89L19.25 4.27H14.56L6.90001 12Z' fill='red'/> <path d='M14.35 21.25C14.2512 21.2522 14.153 21.2338 14.0618 21.1959C13.9705 21.158 13.8882 21.1015 13.82 21.03L2.52 9.73999C2.38752 9.59782 2.3154 9.40977 2.31883 9.21547C2.32226 9.02117 2.40097 8.83578 2.53838 8.69837C2.67579 8.56096 2.86118 8.48224 3.05548 8.47882C3.24978 8.47539 3.43783 8.54751 3.58 8.67999L14.88 20C15.0205 20.1406 15.0993 20.3312 15.0993 20.53C15.0993 20.7287 15.0205 20.9194 14.88 21.06C14.7353 21.1907 14.5448 21.259 14.35 21.25Z' fill='red'/> <path d='M6.5 21.19C6.31632 21.1867 6.13951 21.1195 6 21L2.55 17.55C2.47884 17.4774 2.42276 17.3914 2.385 17.297C2.34724 17.2026 2.32855 17.1017 2.33 17C2.33 16.59 2.33 16.58 6.45 12.58C6.59063 12.4395 6.78125 12.3607 6.98 12.3607C7.17876 12.3607 7.36938 12.4395 7.51 12.58C7.65046 12.7206 7.72934 12.9112 7.72934 13.11C7.72934 13.3087 7.65046 13.4994 7.51 13.64C6.22001 14.91 4.82 16.29 4.12 17L6.5 19.38L9.86 16C9.92895 15.9292 10.0114 15.873 10.1024 15.8346C10.1934 15.7962 10.2912 15.7764 10.39 15.7764C10.4888 15.7764 10.5866 15.7962 10.6776 15.8346C10.7686 15.873 10.8511 15.9292 10.92 16C11.0605 16.1406 11.1393 16.3312 11.1393 16.53C11.1393 16.7287 11.0605 16.9194 10.92 17.06L7 21C6.8614 21.121 6.68402 21.1884 6.5 21.19Z' fill='red'/>",
    //         SVGFOOTER));
    //     return svg;
    // }    

    // function tokenURI(uint256 tokenId) override(ERC721Upgradeable) public view returns (string memory) {

    //     IProvince province = IProvince(provinces[tokenId]);

    //     string memory name = tokenId.toString();
    //     bytes memory dataURI = abi.encodePacked(
    //         '{"name": "',name ,'",',
    //         '"image_data": "', getSvg(), '",',
    //         '"attributes": [',
    //         '{"trait_type": "Plains", "value": ', uint256(100).toString(), '},',
    //         '{"trait_type": "Forest", "value": ', uint256(100).toString(), '},',
    //         '{"trait_type": "Moutain", "value": ', uint256(100).toString(), '},',
    //         ']}'
    //     );

    //     return string(
    //         abi.encodePacked(
    //             "data:application/json;base64,",
    //             Base64.encode(dataURI)
    //         )
    //     );
    // } 
}
