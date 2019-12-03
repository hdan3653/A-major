// for microbit-green
// receive number via radio
// serial write to PC

radio.onReceivedNumber(function (receivedNumber) {
    serial.writeNumber(receivedNumber) // serial write
    
    // for debug
    if (receivedNumber == 1) { // from blue
        led.plot(2, 0)
        basic.pause(100)
        led.unplot(2, 0)
    } else if (receivedNumber == 2) { // from yellow
        led.plot(2, 4)
        basic.pause(100)
        led.unplot(2, 4)
    }
})
radio.setGroup(1)
basic.forever(function () {
	
})
