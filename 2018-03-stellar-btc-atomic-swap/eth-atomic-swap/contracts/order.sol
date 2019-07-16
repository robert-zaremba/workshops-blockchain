pragma solidity ^0.4.17;

import "./erc20.sol";

// TODO owner, stop

contract Order {

    ERC20 icoToken;
    uint hardCap = 0;
    uint maxContrib = 0;
    uint sPrice = 0;
    uint pExp = 0;
    uint pConst = 0;
    uint maxTime = 0;
    uint sTime = 0;

    uint lastTime = 0;
    uint finalPrice = 0;
    bool closed = false;

    mapping(address => uint) orders;
    uint totalOrders = 0;

    function Order(address _icoToken,  uint _hardCap,
          uint _sPrice, uint _pExp,
          uint _pConst, uint _maxContrib,
          uint _maxTime) {
        require(_pConst > 0);
        require(_pExp > 1);
        require(_hardCap > 0);
        require(_sPrice > 0);

        icoToken = ERC20(_icoToken);
        sTime = now;
        hardCap = _hardCap;
        sPrice = _sPrice;
        pExp = _pExp;
        pConst = _pConst;
        maxContrib = _maxContrib;
        maxTime = _maxTime;
    }

    function makeOrder() payable {
        require(hardCap >= totalOrders + msg.value);
        var val = orders[msg.sender];
        require(val + msg.value <= maxContrib);
        orders[msg.sender] = val + msg.value;

        totalOrders += msg.value;
        lastTime = now;

        close();
    }

    function computePrice(uint time) view returns(uint) {
        var t = time - sTime;
        return sPrice*(1 + t) / (1+t + power(t, pExp) / pConst);
    }

    function power(uint a, uint b) pure returns(uint) {
        uint result = a;
        for(;b > 1; b--)
            result = result * a;
        return result;
    }

    function close() {
        if (hardCap <= totalOrders ||
            now >= maxTime) {

            closed = true;
            finalPrice = computePrice(lastTime);
        }
    }

    function withdraw () returns(bool) {
        require(closed);
        return icoToken.transfer(msg.sender,
                 orders[msg.sender] * finalPrice);
    }
}
