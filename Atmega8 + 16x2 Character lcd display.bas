'======================================================================='

' Title: Lcd Display PID Temperature Controller
' Last Updated :  05.2022
' Author : A.Hossein.Khalilian
' Program code  : BASCOM-AVR 2.0.8.5
' Hardware req. : Atmega8 + 16x2 Character lcd display

'======================================================================='

$regfile = "m8def.dat"
$crystal = 1000000
$swstack = 40
$hwstack = 32
$framesize = 32

Config Lcd = 16 * 4
Config Lcdpin = Pin , Db4 = Portb.3 , Db5 = Portb.2 , Db6 = Portb.1 , _
Db7 = Portb.0 , E = Portb.4 , Rs = Portb.5
Cursor Off

Config Adc = Single , Prescaler = Auto , Reference = Avcc
Start Adc

Config Pind.5 = Input
Config Pind.6 = Input
Config Pind.7 = Input

Up Alias Pind.6
Down Alias Pind.7
Config Portd.3 = Output
Config Portd.4 = Output
Config Portd.5 = Output

Fan Alias Portd.3
Heater Alias Portd.4
Motor Alias Portd.5
Fan = 0
Heater = 0

Dim X As Byte
Dim Y As Byte
Dim Z As Byte
Dim E As Byte
Dim W As Word
Dim W_single As Single
Dim W_avg As Single
Dim Pv As Integer
Dim Gp As Byte
Dim Sv As Integer , Sv_s As Eram Integer
Dim Hv_h As Integer , Hv_l As Integer


Deflcdchar 0 , 4 , 14 , 31 , 14 , 4 , 32 , 32 , 32

Cls
Lcd "PT=" ; Spc(3) ; Chr(0) ; "C" ; Spc(2) ; "HT="
Lowerline
Lcd "ST=" ; Spc(3) ; Chr(0) ; "C" ; Spc(2) ; "FN="

Sv = Sv_s

'--------------------------------------------

Main:
Gosub Measure_lm35
Gosub Check_temp
Debounce Up , 0 , Sv_up
Debounce Down , 0 , Sv_down
Goto Main

'--------------------------------------------

Measure_lm35:

W_avg = 0
For Gp = 1 To 100
W = Getadc(0)
If W <> 0 Then
W_single = W / 2

Else
W_single = 0
End If

W_avg = W_avg + W_single
Next Gp
If W_avg <> 0 Then
W_avg = W_avg / 100

Else
W_avg = 0
End If

Pv = W_avg
Locate 1 , 4
Lcd Spc(3)
Locate 1 , 4
Lcd Pv
Locate 2 , 4
Lcd Spc(3)
Locate 2 , 4
Lcd Sv
X = W_single * .85
Y = W_single * .67
Z = W_single * .15
E = Sv - pv

Locate 3 , 1
Lcd "KP" ; Spc(1) ; "KI" ; Spc(1) ; "KD"
Locate 4 , 1
Lcd X ; Spc(1) ; Y ; Spc(1) ; Z ;

Return

''''''''''''''''''''''''''''

Sv_up:
Incr Sv
If Sv > 110 Then
Sv = 0
End If

Sv_s = Sv
Locate 2 , 4
Lcd Spc(3)
Locate 2 , 4
Lcd Sv
Goto Main

''''''''''''''''''''''''''''

Sv_down:
If Sv <> 0 Then
Decr Sv
Else
Sv = 110
End If

Sv_s = Sv
Locate 2 , 4
Lcd Spc(3)
Locate 2 , 4
Lcd Sv
Goto Main

''''''''''''''''''''''''''''

Check_temp:
Hv_h = Sv + 1
If Pv >= Hv_h Then
Fan = 1
Heater = 0
Locate 1 , 14
Lcd Spc(3)
Locate 1 , 14
Lcd "OFF"
Locate 2 , 14
Lcd Spc(3)
Locate 2 , 14
Lcd "ON"
End If

Hv_l = Sv - 1
If Pv <= Hv_l Then
Fan = 0
Heater = 1
Locate 1 , 14
Lcd Spc(3)
Locate 1 , 14
Lcd "ON"
Locate 2 , 14
Lcd Spc(3)
Locate 2 , 14
Lcd "OFF"
End If

If Pv > Hv_l And Pv < Hv_h Then
Fan = 0
Heater = 0
Locate 1 , 14
Lcd Spc(3)
Locate 1 , 14
Lcd "OFF"
Locate 2 , 14
Lcd Spc(3)
Locate 2 , 14
Lcd "OFF"
End If

If E < 2 Then
Motor = 1
Locate 3 , 11
Lcd "MT=ON "
Else
Motor = 0
Locate 3 , 11
Lcd "MT=OFF"
End If

X = 0
Y = 0
Z = 0

Return
End

'--------------------------------------------