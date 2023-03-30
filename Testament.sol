// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract Testament{
   
    // Определение владельца
    constructor (){
        OwnerAddress = msg.sender;
    }

    address payable [] HeirsAddress;
    address OwnerAddress;
    address payable lawyer;

    uint Asset;
    uint AssetCheck;
    uint counts;

    mapping (address => uint) AssetForHeirs;

    bool IsDead;
    bool Assets_distributed;

    // Получение перевода на смарт контракт
    receive() external payable {
        Asset = Asset + msg.value;
        AssetCheck = Asset;
    }   

    // Вывод всего наследства
    function GetAsset() public view returns(uint){
        return (Asset);
    }

    // Вывод доступного наследства
    function CheckAsset() public view returns(uint){
        return (AssetCheck);
    }

    // Проверка на владельца контракта
    modifier OnlyOwner{
        require (msg.sender == OwnerAddress,"OnlyOwner can do it");
        _;
    }

    // Проверка на адвоката
    modifier OnlyLawer{
       require(msg.sender == lawyer, "OnlyLawer can do it");
       _;
    }

    // Задать адвоката
    function SetLawyer(address payable _address) public OnlyOwner {
        lawyer = _address;
    }

    // Вывести адвоката
    function GetLawyer() public view returns(address){
        return (lawyer);
    }
    
    // Установить наследников
    function setHeirs(address payable _address, uint amount) public OnlyOwner{
        require(IsDead == false, "Sorry Owner died...");
        require(AssetCheck >= amount, "There is no asset for this heir");
        AssetForHeirs[_address] = amount;
        HeirsAddress.push(_address);
        AssetCheck = AssetCheck - amount;
    }

    // Вывод планируемого наследства для наследников
    function GetAssetForHeirs(address _address) public view returns(uint){
        return (AssetForHeirs[_address]);
    }

    // Адвокат устанавливает что владелец мертв
    function OwnerDie() public OnlyLawer{
        IsDead = true;
        AssetDistribution();
    }
    
    // Вывод жив ли владелец
    function GetStatus() public view returns(bool){
        return (IsDead);
    }

    // Раздача наследства
    function AssetDistribution() public payable OnlyLawer {
        require(IsDead == true);//The owner must be dead
        require (counts == 0, "Can only be used once..");
        for(uint i=0;i<HeirsAddress.length;i++){
        HeirsAddress[i].transfer(AssetForHeirs[HeirsAddress[i]]);
        counts += 1; //To distribute assets only once
        }
        Assets_distributed = true;
    }

    // Вывод раздано ли наследство
    function distributed_Check() public view returns(bool){
        return Assets_distributed;
    }
}