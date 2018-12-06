INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100] ; Our code here

EntryPoint: ; Global function where execution begins
    di ; Disable interrupts
    jp Start ; Blast outta this tiny space
    
REPT $150 - $104
    db 0
ENDR

SECTION "Code", ROM0

Start: ; Global function to initiate LCD
.waitVBlank ; Turn off LCD
    ld a, [rLY]
    cp 144 ; Check if the LCD is past VBlank
    jr c, .waitVBlank
    
    xor a ; ld a, 0 ; We only need to reset a value with 7 bit reset, but 0 does the job
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really
    
    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyfont
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de ; Move to next byte
    dec bc ; Decrement count
    ld a, b ; Check if count is 0, since 'dec bc' doesn't update flags
    or c 
    jr nz, .copyfont
    
    ld hl, $9800 ; Prints string at top left of screen
    ld de, HelloWorldStr
.copystring
    ld a, [de]
    ld [hli], a
    inc de
    and a ; Check if byte we just copied is 0
    jr nz, .copystring ; Continue if it's not
    
    ; Init display registers
    ld a, %11100100
    ld [rBGP], a
    
    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a
    
    ; Shut sound down
    ld [rNR52], a
    
    ; Turn screen on, display backround
    ld a, %10000001
    ld [rLCDC], a
    
    ; Lock Up
.lockup
    jr .lockup
    
SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "Hello World", ROM0

HelloWorldStr
    db "Hello World", 0
    
    
    
    