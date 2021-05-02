pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
 
 
contract ERC20Token{
    
    function mint(address, uint) public   {} 
        
    function burn(address, uint) public   {} 

}


/**
 * @title Staking Token (STK)
 */
 
contract Stake is Ownable {
     
     struct stakingInfo {
        uint amount;
        uint releaseDate;
    }
    
    ERC20Token Stakeable ;
    ERC20Token RewardToken ;

    
    constructor(address _Stakeable, address _RewardToken) public  Ownable() { 
         
        Stakeable = ERC20Token(_Stakeable) ;
        RewardToken = ERC20Token(_RewardToken) ;

    }

    /**
     * @notice We usually require to know who are all the stakeholders.
     */
    address[] internal stakeholders;

    /**
     * @notice The stakes for each stakeholder.
     */
    mapping(address => stakingInfo) internal stakes;

    /**
     * @notice The accumulated rewards for each stakeholder.
     */
    mapping(address => uint256) internal rewards;

  
    // ---------- STAKES ----------

    /**
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint256 _stake)
        public
    {
        Stakeable.burn(msg.sender, _stake);
        if(stakes[msg.sender].amount == 0) addStakeholder(msg.sender);
        stakes[msg.sender].amount = stakes[msg.sender].amount + _stake;  // no need for safeMath since pragma 8 prevents memory corruption vuln (buffer underflow ....)
        stakes[msg.sender].releaseDate = block.timestamp + 30 days ;    // too many edge cases but i tried to keep it simple any time the stakeholder add additional stakes we lock him for 30 days (restart the counter)
    }

    /**
     * @notice A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function removeStake(uint256 _stake)
        private
    {   
        stakes[msg.sender].amount = stakes[msg.sender].amount - _stake;
        if(stakes[msg.sender].amount == 0) removeStakeholder(msg.sender);
        Stakeable.mint(msg.sender, _stake);  
    }

    /**
     * @notice A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder].amount;
    }

    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes + stakes[stakeholders[s]].amount;
        }
        return _totalStakes;
    }

    // ---------- STAKEHOLDERS ----------

    /**
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
     * @notice A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder)
        private
        
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /**
     * @notice A method to remove a stakeholder.
     * @param _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder)
        private
        
        
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }

    // ---------- REWARDS ----------
    
    /**
     * @notice A method to allow a stakeholder to check his rewards.
     * @param _stakeholder The stakeholder to check rewards for.
     */
    function rewardOf(address _stakeholder) 
        public
        view
        returns(uint256)
    {
        return rewards[_stakeholder];
    }

    /**
     * @notice A method to the aggregated rewards from all stakeholders.
     * @return uint256 The aggregated rewards from all stakeholders.
     */
  /**  function totalRewards()
        public
        view
        returns(uint256)
    {
        uint256 _totalRewards = 0; 
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalRewards = _totalRewards + rewards[stakeholders[s]];
        }
        return _totalRewards;
    }

    /** 
     * @notice A simple method that calculates the rewards for each stakeholder.
     * @param _stakeholder The stakeholder to calculate rewards for.
     */
    function calculateReward(address _stakeholder)
        private
         
        view
        returns(uint256)
    {   
        if (stakes[_stakeholder].amount >= 100  && stakes[_stakeholder].amount < 1000 )
    
        return (((block.timestamp  - stakes[_stakeholder].releaseDate) / 1 days )  + 30 )*10;
        
        if (stakes[_stakeholder].amount >= 1000  && stakes[_stakeholder].amount < 10000 )
      
        return (((block.timestamp  - stakes[_stakeholder].releaseDate) / 1 days )  + 30 )*20;
        
         if (stakes[_stakeholder].amount >= 10000 )
         
        return (((block.timestamp  - stakes[_stakeholder].releaseDate) / 1 days )  + 30 )*30;
        
    }

    /**
     * @notice A method to distribute rewards to all stakeholders.
     */
    function GetRewardsinfo()  // facultatif method
        public
        onlyOwner  
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder] + (reward);
        }
    }

    /**
     * @notice A method to allow a stakeholder to withdraw his rewards.
     */
    function withdrawReward() 
        public
    {   require(stakes[msg.sender].releaseDate < block.timestamp && stakes[msg.sender].amount > 0)   ;
        uint256 reward = calculateReward(msg.sender);
       
        RewardToken.mint(msg.sender, reward);
        removeStake(stakes[msg.sender].amount);

    }  
}