// for microbit-blue
// send 1 via radio

input.onButtonPressed(Button.A, function () {
    radio.sendNumber(1)
    led.plot(2, 2)
})
radio.setGroup(1)
basic.forever(function () {
	
})
