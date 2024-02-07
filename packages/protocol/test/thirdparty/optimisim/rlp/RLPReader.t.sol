// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "../../../TaikoTest.sol";

contract TestRLPReader is TaikoTest {
    function test_readList_correctList() public {
        bytes memory encodedList = hex"c3010203"; // "[0x01, 0x02, 0x03]"
        RLPReader.RLPItem[] memory decodedList = RLPReader.readList(encodedList);
        assertEq(decodedList.length, 3);
        assertEq(RLPReader.readBytes(decodedList[0]), hex"01");
        assertEq(RLPReader.readBytes(decodedList[1]), hex"02");
        assertEq(RLPReader.readBytes(decodedList[2]), hex"03");
    }

    function test_readList_emptyList() public {
        bytes memory encodedList = hex"c0"; // "[]"
        RLPReader.RLPItem[] memory decodedList = RLPReader.readList(encodedList);
        assertEq(decodedList.length, 0);
    }

    function test_readList_emptyListNull() public {
        bytes memory encodedList = hex"c180"; // "[""]"
        RLPReader.RLPItem[] memory decodedList = RLPReader.readList(encodedList);
        assertEq(decodedList.length, 1);
        assertEq(RLPReader.readBytes(decodedList[0]), hex"");
    }

    function test_readList_nestedList() public {
        bytes memory encodedList = hex"c3c10102"; // "[["0x01"],"0x02"]"
        RLPReader.RLPItem[] memory decodedList = RLPReader.readList(encodedList);
        assertEq(decodedList.length, 2);
        assertEq(RLPReader.readBytes(decodedList[1]), hex"02");
        RLPReader.RLPItem[] memory nestedDecodedList = RLPReader.readList(decodedList[0]);
        assertEq(nestedDecodedList.length, 1);
        assertEq(RLPReader.readBytes(nestedDecodedList[0]), hex"01");
    }

    function test_readList_invalidLength() public {
        bytes memory encodedList = hex"e1a00000000000000000000000000000000000000000000000000001";
        vm.expectRevert("RLPReader: length of content must be greater than list length (short list)");
        RLPReader.readList(encodedList);
    }

    function test_readList_empty() public {
        bytes memory empty = hex"";
        vm.expectRevert("RLPReader: length of an RLP item must be greater than zero to be decodable");
        RLPReader.readList(empty);
    }

    function test_readList_null() public {
        bytes memory encodedNull = hex"80";
        vm.expectRevert("RLPReader: decoded item type for list is not a list item");
        RLPReader.readList(encodedNull);
    }

    function test_readList_nonList() public {
        bytes memory encodedNumber = hex"8204d2"; // "1234"
        vm.expectRevert("RLPReader: decoded item type for list is not a list item");
        RLPReader.readList(encodedNumber);
    }

    function test_readBytes_correctFourBytes() public {
        bytes memory encodedBytes = hex"8412345678"; // "0x12345678"
        bytes memory decodedBytes = RLPReader.readBytes(encodedBytes);
        assertEq(decodedBytes.length, 4);
        assertEq(decodedBytes, hex"12345678");
    }

    function test_readBytes_correctSixtyFourBytes() public {
        bytes memory encodedBytes = hex"b8400123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
        bytes memory decodedBytes = RLPReader.readBytes(encodedBytes);
        assertEq(decodedBytes.length, 64);
        assertEq(decodedBytes, hex"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");

    }

    function test_readBytes_null() public {
        bytes memory encodedBytes = hex"80";
        assertEq(RLPReader.readBytes(encodedBytes), hex"");
    }

    function test_readBytes_empty() public {
        bytes memory empty = hex"";
        vm.expectRevert("RLPReader: length of an RLP item must be greater than zero to be decodable");
        RLPReader.readBytes(empty);
    }

    function test_readBytes_list() public {
        bytes memory encodedList = hex"c3010203"; // "[0x01, 0x02, 0x03]"
        vm.expectRevert("RLPReader: decoded item type for bytes is not a data item");
        RLPReader.readBytes(encodedList);
    }

    function test_readRawBytes_shortBytes() public {
        bytes memory encodedBytes = hex"940123456789012345678901234567890123456789";
        assertEq(RLPReader.readRawBytes(RLPReader.toRLPItem(encodedBytes)), encodedBytes);
    }

    function test_readRawBytes_longBytes() public {
        bytes memory encodedBytes = hex"b8400123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
        assertEq(RLPReader.readRawBytes(RLPReader.toRLPItem(encodedBytes)), encodedBytes);
    }

    function test_readRawBytes_empty() public {
        bytes memory encodedBytes = hex"";
        vm.expectRevert("RLPReader: length of an RLP item must be greater than zero to be decodable");
        RLPReader.readRawBytes(RLPReader.toRLPItem(encodedBytes));
    }

    function test_readRawBytes_null() public {
        bytes memory encodedBytes = hex"80";
        assertEq(RLPReader.readRawBytes(RLPReader.toRLPItem(encodedBytes)), encodedBytes);
    }

}