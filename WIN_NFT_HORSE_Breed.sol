pragma solidity ^0.5.5;

import "./EnumerableSet.sol";
import "./Strings.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./ITRC20.sol";
import "./IHorse.sol";

contract WIN_NFT_HORSE_Breed is Ownable {
    uint8 constant ATTR_CLS = 30;
    uint8 constant ATTR_SEX = 29;
    uint8 constant ATTR_COLOR = 28;
    uint8 constant ATTR_PATTERN = 27;
    uint8 constant ATTR_LEFT_FRONT_LEG = 26;
    uint8 constant ATTR_LEFT_HIND_LEG = 25;
    uint8 constant ATTR_RIGHT_FRONT_LEG = 24;
    uint8 constant ATTR_RIGHT_HIND_LEG = 23;
    uint8 constant ATTR_SPECIAL = 22;
    uint8 constant ATTR_SPEED = 20;
    uint8 constant ATTR_STAMINA = 18;
    uint8 constant ATTR_BALANCE = 16;
    uint8 constant ATTR_BURST = 14;
    uint8 constant ATTR_SKILL1 = 12;
    uint8 constant ATTR_SKILL2 = 10;
    uint8 constant ATTR_SKILL3 = 8;
    uint8 constant ATTR_SKILL4 = 6;
    uint8 constant ATTR_QTE_IN_1 = 5;
    uint8 constant ATTR_QTE_IN_2 = 4;
    uint8 constant ATTR_QTE_IN_3 = 3;
    uint8 constant ATTR_QTE_OUT_1 = 2;
    uint8 constant ATTR_QTE_OUT_2 = 1;
    uint8 constant ATTR_QTE_OUT_3 = 0;

    uint256 private nonce = 0;

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;

    address public TOKEN_WIN_ADDRESS;

    address public TOKEN_NFT_ADDRESS;

    address public CORE_ADDRESS;

    mapping(uint256 => uint256) public NFT_PRICE;

    uint256 public WIN_PRICE = 22500 * 1000000;

    address public empty_address = address(0x410000000000000000000000000000000000000001);

    struct parents {
        uint256 father;
        uint256 mother;
    }

    mapping(uint256 => uint256) public had_breed_map;

    mapping(uint256 => parents) public parents_map;

    mapping(uint256 => uint256[]) public children_map;

    event Breed(address breeder, uint256 father, uint256 mother, uint256 horse_id, uint256 child_genes);
    event ParentCount(address breeder, uint256 father, uint256 mother, uint256 father_breed_count, uint256 mother_breed_count);

    struct range {
        uint16 min;
        uint16 max;
    }

    mapping(uint256 => range) public configs_map;

    constructor(address win_address, address nft_address, address core_address) public {
        TOKEN_WIN_ADDRESS = win_address;
        TOKEN_NFT_ADDRESS = nft_address;
        CORE_ADDRESS = core_address;
        configs_map[1] = range(100, 115);
        configs_map[2] = range(110, 125);
        configs_map[3] = range(120, 140);
        configs_map[4] = range(130, 155);
        configs_map[5] = range(140, 175);
        configs_map[6] = range(160, 190);
        configs_map[7] = range(180, 210);
        configs_map[8] = range(220, 250);
        configs_map[101] = range(160, 250);
        configs_map[102] = range(160, 250);
        configs_map[103] = range(160, 250);

        NFT_PRICE[0] = 370000 * 1000000;
        NFT_PRICE[1] = 555000 * 1000000;
        NFT_PRICE[2] = 740000 * 1000000;
        NFT_PRICE[3] = 1295000 * 1000000;
        NFT_PRICE[4] = 1850000 * 1000000;
        NFT_PRICE[5] = 3700000 * 1000000;
        NFT_PRICE[6] = 5555000 * 1000000;
    }


    function SET_CORE_ADDRESS(address core) public onlyOwner returns (address){
        CORE_ADDRESS = core;
        return CORE_ADDRESS;
    }

    function SET_TOKEN_WIN_ADDRESS(address win) public onlyOwner returns (address){
        TOKEN_WIN_ADDRESS = win;
        return TOKEN_WIN_ADDRESS;
    }

    function SET_TOKEN_NFT_ADDRESS(address nft) public onlyOwner returns (address){
        TOKEN_NFT_ADDRESS = nft;
        return TOKEN_NFT_ADDRESS;
    }

    function SET_NFT_PRICE(uint256 breed_count, uint256 price) public onlyOwner returns (uint256){
        NFT_PRICE[breed_count] = price;
        return NFT_PRICE[breed_count];
    }

    function SET_WIN_PRICE(uint256 price) public onlyOwner returns (uint256){
        WIN_PRICE = price;
        return WIN_PRICE;
    }

    function balanceOf_APENFT() public view returns (uint256) {
        IERC20 token_nft = IERC20(TOKEN_NFT_ADDRESS);
        return token_nft.balanceOf(address(this));
    }

    function balanceOf_WIN() public view returns (uint256) {
        IERC20 token_win = IERC20(TOKEN_WIN_ADDRESS);
        return token_win.balanceOf(address(this));
    }

    function withdraw_APENFT(uint256 amount, address to) public onlyOwner returns (bool){
        IERC20 token_nft = IERC20(TOKEN_NFT_ADDRESS);
        return token_nft.transferFrom(address(this), to, amount);
    }

    function withdraw_WIN(uint256 amount, address to) public onlyOwner returns (bool) {
        IERC20 token_win = IERC20(TOKEN_WIN_ADDRESS);
        return token_win.transferFrom(address(this), to, amount);
    }

    function StartBreed(uint256 father_token_id, uint256 mother_token_id) public returns (uint256){

        require(had_breed_map[father_token_id] < 7, "father breed count");
        require(had_breed_map[mother_token_id] < 7, "mother breed count");

        uint256 REAL_NFT_PRICE = NFT_PRICE[had_breed_map[father_token_id]] + NFT_PRICE[had_breed_map[mother_token_id]];
        if (REAL_NFT_PRICE > 0) {
            IERC20 token_nft = IERC20(TOKEN_NFT_ADDRESS);
            bool token_nft_success = token_nft.transferFrom(msg.sender, address(this), REAL_NFT_PRICE);
            require(token_nft_success, "token_nft transferFrom");
        }
        if (WIN_PRICE > 0) {
            IERC20 token_win = IERC20(TOKEN_WIN_ADDRESS);
            bool token_win_success = token_win.transferFrom(msg.sender, address(this), WIN_PRICE);
            require(token_win_success, "token_win transferFrom");
        }

        uint256 child_id = _safeBreed(father_token_id, mother_token_id);

        had_breed_map[father_token_id] = had_breed_map[father_token_id].add(1);
        had_breed_map[mother_token_id] = had_breed_map[mother_token_id].add(1);
        parents_map[child_id] = parents(father_token_id, mother_token_id);
        children_map[father_token_id].push(child_id);
        children_map[mother_token_id].push(child_id);

        emit ParentCount(msg.sender, father_token_id, mother_token_id, had_breed_map[father_token_id], had_breed_map[mother_token_id]);

        return child_id;
    }

    function _safeBreed(uint256 father_token_id, uint256 mother_token_id) private returns (uint256){

        IHorse core = IHorse(CORE_ADDRESS);
        require(father_token_id != 0, "father_token_id==0");
        require(mother_token_id != 0, "mother_token_id==0");
        require(father_token_id != mother_token_id, "father_token_id == mother_token_id");

        address father_owner = core.ownerOf(father_token_id);
        address mother_owner = core.ownerOf(mother_token_id);
        require(father_owner == msg.sender, "father not belongs you");
        require(mother_owner == msg.sender, "mother not belongs you");

        (uint256 father_genes, uint256 father_date) = core.getHorse(father_token_id);
        (uint256 mother_genes,uint256 mother_date) = core.getHorse(mother_token_id);

        require(getGene8(father_genes, ATTR_SEX) != getGene8(mother_genes, ATTR_SEX), "parents cannot be the same gender");

        uint256 father_cls = getGene8(father_genes, ATTR_CLS);
        uint256 mother_cls = getGene8(mother_genes, ATTR_CLS);

        if (father_cls >= 200 || mother_cls >= 200) {
            revert();
        }

        if (father_cls >= 100 || mother_cls >= 100) {
            if (father_cls != mother_cls) {
                revert();
            }
        }

        uint256 child_genes = 0;
        child_genes = _makeChildGenes(father_genes, mother_genes);


        uint256 child_id = core.spawnHorse(child_genes, msg.sender);


        emit Breed(msg.sender, father_token_id, mother_token_id, child_id, child_genes);
        return child_id;
    }

    function calculate_fightvalue(uint256 genes) private pure returns (uint256){
        return _calculate_fightvalue(getGene8(genes, ATTR_SPEED), getGene8(genes, ATTR_STAMINA), getGene8(genes, ATTR_BALANCE), getGene8(genes, ATTR_BURST));
    }

    function _calculate_fightvalue(uint256 speed, uint256 stamina, uint256 balance, uint256 burst) private pure returns (uint256){

        return (speed * (2 + (burst - 100) / 100.0) + burst * (1 + ((speed - 100) / 100.0 +
        (balance - 100) / 100.0) / 2 + (stamina - 100) / 100.0) + stamina * (1 + (burst - 100) / 100.0)
        + balance * (2 + (burst - 100) / 100.0));

    }

    function getGene8(uint256 x, uint8 offset) public pure returns (uint8) {
        return uint8(x >> (8 * offset));
    }

    function getGene16(uint256 x, uint8 offset) public pure returns (uint16) {
        return uint16(x >> (8 * offset));
    }


    function setGene8(uint256 source, uint8 x, uint8 offset) public pure returns (uint256) {
        uint256 temp = x;
        temp = temp << (8 * offset);
        return source + temp;
    }

    function setGene16(uint256 source, uint16 x, uint8 offset) public pure returns (uint256){
        uint256 temp = x;
        temp = temp << (8 * offset);
        return source + temp;
    }

    function makeChildGenes(uint256 father_genes, uint256 mother_genes) public returns (bytes32){
        return bytes32(_makeChildGenes(father_genes, mother_genes));
    }


    function _makeChildGenes(uint256 father_genes, uint256 mother_genes) public returns (uint256){

        uint256 f_value = _calculate_fightvalue(getGene16(father_genes, ATTR_SPEED), getGene16(father_genes, ATTR_STAMINA), getGene16(father_genes, ATTR_BALANCE), getGene16(father_genes, ATTR_BURST));
        uint256 m_value = _calculate_fightvalue(getGene16(mother_genes, ATTR_SPEED), getGene16(mother_genes, ATTR_STAMINA), getGene16(mother_genes, ATTR_BALANCE), getGene16(mother_genes, ATTR_BURST));

        uint256 child_genes = 0;

        nonce++;
        uint8 cls = 0;
        if (uint256(keccak256(abi.encodePacked(now + nonce))) % 100 < 75) {
            //继承低级
            cls = getGene8(father_genes, ATTR_CLS) < getGene8(mother_genes, ATTR_CLS) ? getGene8(father_genes, ATTR_CLS) : getGene8(mother_genes, ATTR_CLS);
            child_genes = setGene8(child_genes, cls, ATTR_CLS);
        } else {
            cls = getGene8(father_genes, ATTR_CLS) > getGene8(mother_genes, ATTR_CLS) ? getGene8(father_genes, ATTR_CLS) : getGene8(mother_genes, ATTR_CLS);
            child_genes = setGene8(child_genes, cls, ATTR_CLS);
        }

        nonce++;
        if (uint256(keccak256(abi.encodePacked(now + nonce))) % 100 > 50) {
            child_genes = setGene8(child_genes, 1, ATTR_SEX);
        } else {
            child_genes = setGene8(child_genes, 2, ATTR_SEX);
        }

        nonce++;
        if (uint256(keccak256(abi.encodePacked(now + nonce))) % 100 > ((f_value * 100) / (f_value + m_value))) {
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_COLOR), ATTR_COLOR);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_PATTERN), ATTR_PATTERN);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_LEFT_FRONT_LEG), ATTR_LEFT_FRONT_LEG);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_LEFT_HIND_LEG), ATTR_LEFT_HIND_LEG);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_RIGHT_FRONT_LEG), ATTR_RIGHT_FRONT_LEG);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_RIGHT_HIND_LEG), ATTR_RIGHT_HIND_LEG);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_SPECIAL), ATTR_SPECIAL);
        } else {
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_COLOR), ATTR_COLOR);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_PATTERN), ATTR_PATTERN);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_LEFT_FRONT_LEG), ATTR_LEFT_FRONT_LEG);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_LEFT_HIND_LEG), ATTR_LEFT_HIND_LEG);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_RIGHT_FRONT_LEG), ATTR_RIGHT_FRONT_LEG);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_RIGHT_HIND_LEG), ATTR_RIGHT_HIND_LEG);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_SPECIAL), ATTR_SPECIAL);
        }

        nonce++;
        child_genes = setGene16(child_genes, range_in(cls), ATTR_SPEED);

        nonce++;
        child_genes = setGene16(child_genes, range_in(cls), ATTR_STAMINA);

        nonce++;
        child_genes = setGene16(child_genes, range_in(cls), ATTR_BALANCE);

        nonce++;
        child_genes = setGene16(child_genes, range_in(cls), ATTR_BURST);

        nonce++;
        if (uint256(keccak256(abi.encodePacked(now + nonce))) % 100 > f_value / (f_value + m_value)) {
            child_genes = setGene16(child_genes, getGene16(father_genes, ATTR_SKILL1), ATTR_SKILL1);
            child_genes = setGene16(child_genes, getGene16(father_genes, ATTR_SKILL2), ATTR_SKILL2);
            child_genes = setGene16(child_genes, getGene16(father_genes, ATTR_SKILL3), ATTR_SKILL3);
            child_genes = setGene16(child_genes, getGene16(father_genes, ATTR_SKILL4), ATTR_SKILL4);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_QTE_IN_1), ATTR_QTE_IN_1);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_QTE_IN_2), ATTR_QTE_IN_2);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_QTE_IN_2), ATTR_QTE_IN_3);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_QTE_OUT_1), ATTR_QTE_OUT_1);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_QTE_OUT_2), ATTR_QTE_OUT_2);
            child_genes = setGene8(child_genes, getGene8(father_genes, ATTR_QTE_OUT_3), ATTR_QTE_OUT_3);
        } else {
            child_genes = setGene16(child_genes, getGene16(mother_genes, ATTR_SKILL1), ATTR_SKILL1);
            child_genes = setGene16(child_genes, getGene16(mother_genes, ATTR_SKILL2), ATTR_SKILL2);
            child_genes = setGene16(child_genes, getGene16(mother_genes, ATTR_SKILL3), ATTR_SKILL3);
            child_genes = setGene16(child_genes, getGene16(mother_genes, ATTR_SKILL4), ATTR_SKILL4);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_QTE_IN_1), ATTR_QTE_IN_1);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_QTE_IN_2), ATTR_QTE_IN_2);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_QTE_IN_3), ATTR_QTE_IN_3);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_QTE_OUT_1), ATTR_QTE_OUT_1);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_QTE_OUT_2), ATTR_QTE_OUT_2);
            child_genes = setGene8(child_genes, getGene8(mother_genes, ATTR_QTE_OUT_3), ATTR_QTE_OUT_3);
        }

        return child_genes;

    }

    function range_in(uint256 cls) private view returns (uint16){
        return uint16((uint256(keccak256(abi.encodePacked(now + nonce))) % (configs_map[cls].max - configs_map[cls].min))) + configs_map[cls].min;
    }

    function setRange(uint256 cls, uint16 min, uint16 max) public onlyOwner {
        configs_map[cls].min = min;
        configs_map[cls].max = max;
    }

}
