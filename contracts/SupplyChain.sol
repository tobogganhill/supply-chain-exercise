
pragma solidity ^0.5.0;

contract SupplyChain {

  // set owner 
  address owner;

  // Add a variable called skuCount to track the most recent sku #
  uint skuCount;

  // mapping that maps the SKU # to an Item
  mapping (uint => Item) items;

  //   Create an enum called State with 4 states:
  //   ForSale
  //   Sold
  //   Shipped
  //   Received
  //   (declaring them in this order is important for testing)
 
  enum State {
      ForSale,
      Sold,
      Shipped,
      Received
    };

  // Create a struct named Item: name, sku, price, state, seller, and buyer
  // "payable" addresses that will be handling value transfer
  
 struct Item {
        string name;
        uint sku;
        uint price;
        uint state;
        address payable seller;
        address payable buyer; 
    }

  // Create 4 events with the same name as each possible State
  // Each event should accept one argument, the sku */

    event LogForSale (uint sku);
    event LogSold (uint sku);
    event LogShipped (uint sku);
    event LogReceived (uint sku);

/* Create a modifer that checks if the msg.sender is the owner of the contract */

  modifier isOwner (address _owner) {
    require (msg.sender = _owner, 'Must be owner to run the contract.');
    _;
  }

  modifier verifyCaller (address _address) {
     require (msg.sender == _address, 'Caller not verified.');
      _;
  }

  modifier paidEnough(uint _price) {
     require(msg.value >= _price, 'Amount paid must be greater than or equal to price.');
     _;
  }

  modifier checkValue(uint _sku) {
    // refund after item paid for
    // underscore at beginning to run this logic at the beginning of the function)
    _;
    uint amountToRefund = msg.value - items[_sku].price;;
    items[_sku].buyer.transfer(amountToRefund);
  }

  /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale. 
   Note that the uninitialized Item.State is 0, which is also the index of the ForSale value,
   so checking that Item.State == ForSale is not sufficient to check that an Item is for sale.
   Hint: What item properties will be non-zero when an Item has been added?
   */
  modifier forSale (uint _sku) {
        require(items[_sku].state == uint(State.ForSale));
        _;
  }

  modifier sold (uint _sku) {
        require(items[_sku].state == uint(State.Sold));
        _;
  }
  

  modifier shipped
  modifier received


  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
  }

  function addItem(string memory _name, uint _price) public returns(bool){
    emit LogForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/

  function buyItem(uint sku)
    public
  {}

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
  function shipItem(uint sku)
    public
  {}

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
  function receiveItem(uint sku)
    public
  {}

  /* We have these functions completed so we can run tests, just ignore it :) */
  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }

}
