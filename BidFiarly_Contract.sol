pragma solidity >=0.5.0;

contract game{
    uint constant public gameCost = 0.1 ether;
    
    address public game_host;
    address [] public winners;
    address [] public joined;
    
    uint public number_of_winners = 0;
    uint public number_of_players = 0;
    uint public total_bidding = 0;
    
    bool game_active = false;
    uint public correct_ans;
    
    struct player_info
    {
        uint player_selected;
        bool participated;
        uint amount_won;
    }
    
    mapping(address=>player_info) map;
    
    constructor() public
    {
        game_host = msg.sender;
        game_active = true;
    }
    
    function join_game(uint player_id) public payable
    {
        require(game_active==true , "Game not started Yet");
        require(map[msg.sender].participated==false , "Already Participated");
        assert(msg.value == gameCost);
        
        map[msg.sender].player_selected = player_id;
        map[msg.sender].participated = true;
        number_of_players++;
        
        joined.push(msg.sender);
        
    }
    
    /// only game host can End the Game
    function end_game(uint result) public
    {
        assert(msg.sender == game_host);
        
        game_active = false;
        correct_ans = result;
        
        total_bidding = (number_of_players*0.1 ether);
        
        // calc no of winners
        uint i;
        for(i=0;i<joined.length;i++)
        {
            if(map[joined[i]].player_selected == result)
            {
                number_of_winners++;
                winners.push(joined[i]);
            }
        }
        uint to_distribute = (total_bidding/number_of_winners);
        
        for(i=0;i<winners.length;i++)
        {
            map[winners[i]].amount_won += to_distribute;
        }
    }
    
    function withdraw_money() public
    {
        require(map[msg.sender].amount_won > 0 , "You don't have money to withdraw");
        
        uint money_withdraw = map[msg.sender].amount_won;
        map[msg.sender].amount_won = 0;
        
        msg.sender.transfer(money_withdraw);
    }
}