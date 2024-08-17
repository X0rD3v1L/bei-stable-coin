pragma solidity 0.8.24;

interface IGem {
    function decimals() external view returns (uint8);
    function transfer(address,uint) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
}

interface ICDPEngine {
    function modify_collateral_balance(bytes32,address,int) external;
}

contract Auth {
    event GrantAuthorization(address indexed usr);
    event DenyAuthorization(address indexed usr);
    mapping (address => bool) public authorized;

    modifier auth {
        require(authorized[msg.sender], "not authorized");
        _;
    }

    constructor () {
        authorized[msg.sender] = true;
        emit GrantAuthorization(msg.sender);
    }
    function grant_auth(address usr) external auth {
        authorized[usr] = true;
        emit GrantAuthorization(usr);
    }
    function deny_auth(address usr) external auth {
        authorized[usr] = false;
        emit DenyAuthorization(usr);
    }
}
contract CircuitBreaker {
    event Stop();

    bool public live;  // Active Flag
    
    constructor () {
        live = true;
    }

    modifier not_stopped(){
        require(live, "not live");
        _;

    }
    function _stop() internal{
        live = false;
        emit Stop();
    }

}
contract GemJoin is Auth, CircuitBreaker{
    ICDPEngine public cdp_engine;   // CDP Engine
    bytes32 public collateral_type;   // Collateral Type
    IGem public gem;
    uint8    public decimals;
    

    // Events
    
    event Join(address indexed usr, uint256 wad);
    event Exit(address indexed usr, uint256 wad);

    constructor(address _cdp_engine, bytes32 _collateral_type, address _gem) {
        cdp_engine = ICDPEngine(_cdp_engine);
        collateral_type = _collateral_type;
        gem = IGem(_gem);
        decimals = gem.decimals();
    }
    
    function stop() external auth {
        _stop();
    }

    //wad = 1e18
    //ray = 1e27
    //rad = 1e45
    function join(address usr, uint wad) external not_stopped{
        require(int(wad) >= 0, "overflow");
        cdp_engine.modify_collateral_balance(collateral_type, usr, int(wad));
        require(gem.transferFrom(msg.sender, address(this), wad), "transfer failed");
        emit Join(usr, wad);
    }
    function exit(address usr, uint wad) external {
        require(wad <= 2 ** 255, "overflow");
        cdp_engine.modify_collateral_balance(collateral_type, msg.sender, -int(wad));
        require(gem.transfer(usr, wad), "transfer failed");
        emit Exit(usr, wad);
    }
}