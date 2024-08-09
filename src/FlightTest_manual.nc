(BHK-postprocessing)
(M03 Red LED on, M04 Red LED off)
(M08 Green LED on, M09 Green LED off)

(Created with Estlcam 12.072)
(Machining time about 00:00:09 hours)

(Required tools:)
(Mode: Milling)
M04
M09
(MBC-M Flach)debug)
G00 X0 Y0

M08
M00
M09
G00 Z10.0000

(No. 1 Engraving machining: Engraving 1)
G00 X10.0000 Y10.0000 Z10.0000
G00 Z0.5000
G01 Z0.0000 F300 S24000
M03
M00
M04
G01 Z-1.0000
G01 Y30.0000 F800
G01 X30.0000
G01 Y10.0000
G01 X10.0000
M08
M00
M09
G00 Z10.0000

m05
M04

