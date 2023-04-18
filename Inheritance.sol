// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract InheritanceContract is ERC721 {
    // Структура, определяющая наследство
    struct Inheritance {
        address heir;       // Адрес наследника
        uint256 amount;     // Количество эфира в наследстве
        string[] items;     // Список предметов в наследстве
    }

    // Переменная, хранящая наследство
    Inheritance public inheritance;

    // Адрес юриста
    address public lawyer;

    // Адрес владельца контракта
    address private owner;

    // Маппинг для связи предметов наследства с их токенами ERC721
    mapping(string => uint256) private itemToTokenId;

    // Конструктор контракта
    constructor() ERC721("InheritanceToken", "INH") {
        owner = msg.sender; // Устанавливаем адрес создателя контракта как владельца
    }

    // Функция для установки наследства
    function setInheritance(address heir, uint256 amount, string[] memory items) external payable {
        require(msg.sender == owner, "Only contract owner can set inheritance");
        require(msg.value == amount, "Deposit amount must be equal to amount");
        inheritance.heir = heir;
        inheritance.amount = amount;
        inheritance.items = items;

        // Создание токена ERC721 для каждого установленного предмета
        for (uint256 i = 0; i < items.length; i++) {
            uint256 tokenId = uint256(keccak256(abi.encodePacked(block.timestamp, i)));
            _mint(msg.sender, tokenId);
            itemToTokenId[items[i]] = tokenId; // Устанавливаем связь между предметом и его токеном
            transferFrom(owner, lawyer, tokenId);
        }
    }

    // Функция для установки юриста
    function setLawyer(address _lawyer) external {
        require(msg.sender == owner, "Only contract owner can set lawyer");
        lawyer = _lawyer;
    }

    // Функция для активации наследства
    function activateInheritance() external payable {
        require(msg.sender == lawyer, "Only lawyer can activate inheritance");
        require(inheritance.amount > 0 || inheritance.items.length > 0, "Inheritance is not set");

        // Передача эфира наследнику
        payable(inheritance.heir).transfer(inheritance.amount);

        // Передача токенов наследнику
        for (uint256 i = 0; i < inheritance.items.length; i++) {
            uint256 tokenId = itemToTokenId[inheritance.items[i]]; // Получаем токен по предмету из маппинга
            transferFrom(lawyer, inheritance.heir, tokenId);
        }

        // Обнуление информации о наследстве
        inheritance.amount = 0;
        inheritance.items = new string[](0);
    }

    // Функция для получения информации о наследстве
    function getInheritanceWithTokenIds() external view returns (uint256, string[] memory, uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](inheritance.items.length);

        for (uint256 i = 0; i < inheritance.items.length; i++) {
            tokenIds[i] = itemToTokenId[inheritance.items[i]];
        }

        return (inheritance.amount, inheritance.items, tokenIds);
    }

    function checkTokenOwner(uint256 tokenId) external view returns (address) {
        // Проверяем владельца токена с использованием функции ownerOf из стандарта ERC721
        return ownerOf(tokenId);
    }

}