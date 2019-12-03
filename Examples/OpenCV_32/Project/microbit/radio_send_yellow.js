// for microbit-yellow
// send 2 via radio

input.onButtonPressed(Button.A, function () {
    radio.sendNumber(2)
    led.plot(2, 2)
})
radio.setGroup(1)
basic.forever(function () {
	
})