pragma solidity ^0.5.0;


contract SupplyChain {
    // set owner
    address owner;

    // Add a variable called skuCount to track the most recent sku #
    uint256 skuCount;

    // mapping that maps the SKU # to an Item
    mapping(uint256 => Item) items;

    //   Create an enum called State with 4 states:
    //   ForSale
    //   Sold
    //   Shipped
    //   Received
    //   (declaring them in this order is important for testing)

    enum State {ForSale, Sold, Shipped, Received}

    // Create a struct named Item: name, sku, price, state, seller, and buyer
    // "payable" addresses that will be handling value transfer

    struct Item {
        string name;
        uint256 sku;
        uint256 price;
        uint256 state;
        address payable seller;
        address payable buyer;
    }

    // Create 4 events with the same name as each possible State
    // Each event should accept one argument, the sku */

    event LogForSale(uint256 sku);
    event LogSold(uint256 sku);
    event LogShipped(uint256 sku);
    event LogReceived(uint256 sku);

    /* Create a modifer that checks if the msg.sender is the owner of the contract */

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address, "Caller not verified.");
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(
            msg.value >= _price,
            "Amount paid must be greater than or equal to price."
        );
        _;
    }

    modifier checkValue(uint256 _sku) {
        // refund after item paid for
        // underscore at beginning to run this logic at the beginning of the function)
        _;
        uint256 amountToRefund = msg.value - items[_sku].price;
        items[_sku].buyer.transfer(amountToRefund);
    }

    /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale. 
   Note that the uninitialized Item.State is 0, which is also the index of the ForSale value,
   so checking that Item.State == ForSale is not sufficient to check that an Item is for sale.
   Hint: What item properties will be non-zero when an Item has been added?
   */
    modifier forSale(uint256 _sku) {
        require(items[_sku].state == uint256(State.ForSale));
        _;
    }

    modifier sold(uint256 _sku) {
        require(items[_sku].state == uint256(State.Sold));
        _;
    }

    modifier shipped(uint256 _sku) {
        require(items[_sku].state == uint256(State.Shipped));
        _;
    }

    modifier received(uint256 _sku) {
        require(items[_sku].state == uint256(State.Received));
        _;
    }

    constructor() public {
        // Set the owner as the person who instantiated the contract
        // and set skuCount to 0.

        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint256 _price)
        public
        returns (bool)
    {
        emit LogForSale(skuCount);
        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: uint256(State.ForSale),
            seller: msg.sender,
            buyer: address(0)
        });
        skuCount = skuCount + 1;
        return true;
    }

    /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/

    function buyItem(uint256 sku)
        public
        payable
        forSale(sku)
        paidEnough(items[sku].price)
        checkValue(sku)
    {
        emit LogSold(sku);
        items[sku].buyer = msg.sender;
        items[sku].state = uint256(State.Sold);
        items[sku].seller.transfer(items[sku].price);
    }

    // Add 2 modifiers to check if the item is sold already, and that the person calling this function
    // is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!
    function shipItem(uint256 sku)
        public
        sold(sku)
        verifyCaller(items[sku].seller)
    {
        emit LogShipped(sku);
        items[sku].state = uint256(State.Shipped);
    }

    /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
    function receiveItem(uint256 sku)
        public
        shipped(sku)
        verifyCaller(items[sku].buyer)
    {
        emit LogReceived(sku);
        items[sku].state = uint256(State.Received);
    }

    /* We have these functions completed so we can run tests, just ignore it :) */
    function fetchItem(uint256 _sku)
        public
        view
        returns (
            string memory name,
            uint256 sku,
            uint256 price,
            uint256 state,
            address seller,
            address buyer
        )
    {
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint256(items[_sku].state);
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
        return (name, sku, price, state, seller, buyer);
    }
}
