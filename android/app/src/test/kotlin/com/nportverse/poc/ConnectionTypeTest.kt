package com.nportverse.poc

import org.junit.Assert
import org.junit.Test

class ConnectionTypeTest {
    @Test
    fun byName_WithValidName_ShouldReturnValidType() {
        // arrange
        val name = "start_advertising"

        // act
        val result = ConnectionType.byName(name)

        // assert
        Assert.assertEquals(ConnectionType.START_ADVERTISING, result)
    }

    @Test
    fun byName_WithInvalidName_ShouldReturnNull() {
        // arrange
        val name = "invalid_name"

        // act
        val result = ConnectionType.byName(name)

        // assert
        Assert.assertEquals(null, result)
    }
}
